const admin = require('./firebaseAdmin'); // Ensure firebaseAdmin is initialized

const db = admin.firestore();

// Example functions for Firestore operations (can be expanded)

/**
 * Get a document from a specified collection.
 * @param {string} collectionName - The name of the collection.
 * @param {string} docId - The ID of the document to retrieve.
 * @returns {Promise<FirebaseFirestore.DocumentSnapshot>} The document snapshot.
 */
async function getDocument(collectionName, docId) {
  try {
    const docRef = db.collection(collectionName).doc(docId);
    const doc = await docRef.get();
    if (!doc.exists) {
      console.log(`No such document: ${collectionName}/${docId}`);
      return null;
    }
    return doc;
  } catch (error) {
    console.error('Error getting document:', error);
    throw error;
  }
}

/**
 * Add a new document to a specified collection.
 * @param {string} collectionName - The name of the collection.
 * @param {object} data - The data for the new document.
 * @returns {Promise<FirebaseFirestore.DocumentReference>} The document reference.
 */
async function addDocument(collectionName, data) {
  try {
    const docRef = await db.collection(collectionName).add(data);
    console.log('Document written with ID: ', docRef.id);
    return docRef;
  } catch (error) {
    console.error('Error adding document:', error);
    throw error;
  }
}

/**
 * Update an existing document in a specified collection.
 * @param {string} collectionName - The name of the collection.
 * @param {string} docId - The ID of the document to update.
 * @param {object} data - The data to update.
 * @returns {Promise<void>}
 */
async function updateDocument(collectionName, docId, data) {
  try {
    const docRef = db.collection(collectionName).doc(docId);
    await docRef.update(data);
    console.log(`Document ${docId} successfully updated in ${collectionName}`);
  } catch (error) {
    console.error('Error updating document:', error);
    throw error;
  }
}

/**
 * Delete a document from a specified collection.
 * @param {string} collectionName - The name of the collection.
 * @param {string} docId - The ID of the document to delete.
 * @returns {Promise<void>}
 */
async function deleteDocument(collectionName, docId) {
  try {
    const docRef = db.collection(collectionName).doc(docId);
    await docRef.delete();
    console.log(`Document ${docId} successfully deleted from ${collectionName}`);
  } catch (error) {
    console.error('Error deleting document:', error);
    throw error;
  }
}

module.exports = {
  db, // Export the raw firestore object if direct access is needed
  getDocument,
  addDocument,
  updateDocument,
  deleteDocument,
};
