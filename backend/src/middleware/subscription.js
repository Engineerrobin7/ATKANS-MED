const Subscription = require('../models/subscription');

const checkSubscription = async (req, res, next) => {
    try {
        const subscription = await Subscription.findOne({ user: req.user._id });

        if (!subscription || subscription.status !== 'active') {
            return res.status(403).json({ message: 'Access denied. No active subscription.' });
        }

        next();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = { checkSubscription };
