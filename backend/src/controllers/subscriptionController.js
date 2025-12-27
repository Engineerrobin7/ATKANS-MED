const Razorpay = require('razorpay');
const { FirestoreHelper, Collections } = require('../config/firestore');
const crypto = require('crypto');

// Lazy initialization of Razorpay
let razorpay = null;
const getRazorpay = () => {
  if (!razorpay && process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
    razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
  }
  return razorpay;
};


exports.createSubscription = async (req, res) => {
  try {
    const { plan, userId } = req.body;

    const razorpayInstance = getRazorpay();
    if (!razorpayInstance) {
      return res.status(503).json({ message: 'Payment service not configured' });
    }

    const user = await FirestoreHelper.findById(Collections.USERS, userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const subscription = await razorpayInstance.subscriptions.create({
      plan_id: plan,
      customer_notify: 1,
    });

    const newSubscription = await FirestoreHelper.create(Collections.SUBSCRIPTIONS, {
      user: userId,
      plan: plan,
      razorpaySubscriptionId: subscription.id,
      status: 'inactive',
      startDate: new Date().toISOString(),
    });

    res.json({ subscriptionId: subscription.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.handleWebhook = async (req, res) => {
  const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
  const shasum = crypto.createHmac('sha256', secret);
  shasum.update(JSON.stringify(req.body));
  const digest = shasum.digest('hex');

  if (digest === req.headers['x-razorpay-signature']) {
    console.log('request is legit');
    const event = req.body.event;
    const payload = req.body.payload;

    console.log(`Received event: ${event}`);

    try {
      const razorpaySubscriptionId = payload.subscription.entity.id;
      // Find subscription by razorpaySubscriptionId
      const subscription = await FirestoreHelper.findOne(Collections.SUBSCRIPTIONS, 'razorpaySubscriptionId', razorpaySubscriptionId);

      if (!subscription) {
        console.error(`Subscription with Razorpay ID ${razorpaySubscriptionId} not found.`);
        return res.status(404).json({ status: 'not found' });
      }

      switch (event) {
        case 'subscription.activated':
          await FirestoreHelper.updateById(Collections.SUBSCRIPTIONS, subscription.id, {
            status: 'active',
            endDate: new Date(payload.subscription.entity.current_end * 1000).toISOString()
          });
          console.log(`Subscription ${subscription.id} activated.`);
          break;
        case 'subscription.charged':
          await FirestoreHelper.updateById(Collections.SUBSCRIPTIONS, subscription.id, {
            endDate: new Date(payload.subscription.entity.current_end * 1000).toISOString()
          });
          console.log(`Subscription ${subscription.id} charged and endDate updated.`);
          break;
        case 'subscription.halted':
          await FirestoreHelper.updateById(Collections.SUBSCRIPTIONS, subscription.id, {
            status: 'cancelled'
          });
          console.log(`Subscription ${subscription.id} cancelled.`);
          break;
        default:
          console.log(`Unhandled event: ${event}`);
      }
    } catch (error) {
      console.error('Error processing webhook:', error);
      return res.status(500).json({ status: 'error' });
    }

  } else {
    console.error('Invalid webhook signature.');
    return res.status(403).json({ status: 'invalid signature' });
  }
  res.json({ status: 'ok' });
};

