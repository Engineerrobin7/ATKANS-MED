const admin = require('./firebaseAdmin');

// Get Firestore instance
let db = null;

const getFirestore = () => {
    if (!db) {
        try {
            db = admin.firestore();
            console.log('✅ Firestore initialized successfully');
        } catch (error) {
            console.warn('⚠️  Firestore not available:', error.message);
            return null;
        }
    }
    return db;
};

// Firestore Collections
const Collections = {
    USERS: 'users',
    PATIENTS: 'patients',
    DOCTORS: 'doctors',
    REPORTS: 'reports',
    PRESCRIPTIONS: 'prescriptions',
    ACCESS_REQUESTS: 'accessRequests',
    ACTIVITY_LOGS: 'activityLogs',
    SUBSCRIPTIONS: 'subscriptions'
};

// Helper functions for common Firestore operations
const FirestoreHelper = {
    // Create a document
    async create(collection, data) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        const docRef = await db.collection(collection).add({
            ...data,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        const doc = await docRef.get();
        return { id: doc.id, ...doc.data() };
    },

    // Create with custom ID
    async createWithId(collection, id, data) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        await db.collection(collection).doc(id).set({
            ...data,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        const doc = await db.collection(collection).doc(id).get();
        return { id: doc.id, ...doc.data() };
    },

    // Find by ID
    async findById(collection, id) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        const doc = await db.collection(collection).doc(id).get();
        if (!doc.exists) return null;
        return { id: doc.id, ...doc.data() };
    },

    // Find one by query
    async findOne(collection, field, value) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        const snapshot = await db.collection(collection)
            .where(field, '==', value)
            .limit(1)
            .get();

        if (snapshot.empty) return null;
        const doc = snapshot.docs[0];
        return { id: doc.id, ...doc.data() };
    },

    // Find all
    async findAll(collection, filters = {}) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        let query = db.collection(collection);

        // Apply filters
        Object.entries(filters).forEach(([field, value]) => {
            query = query.where(field, '==', value);
        });

        const snapshot = await query.get();
        return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    },

    // Update by ID
    async updateById(collection, id, data) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        await db.collection(collection).doc(id).update({
            ...data,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        const doc = await db.collection(collection).doc(id).get();
        return { id: doc.id, ...doc.data() };
    },

    // Delete by ID
    async deleteById(collection, id) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        await db.collection(collection).doc(id).delete();
        return { id, deleted: true };
    },

    // Count documents
    async count(collection, filters = {}) {
        const db = getFirestore();
        if (!db) throw new Error('Firestore not initialized');

        let query = db.collection(collection);

        Object.entries(filters).forEach(([field, value]) => {
            query = query.where(field, '==', value);
        });

        const snapshot = await query.get();
        return snapshot.size;
    }
};

module.exports = {
    getFirestore,
    Collections,
    FirestoreHelper,
    admin
};
