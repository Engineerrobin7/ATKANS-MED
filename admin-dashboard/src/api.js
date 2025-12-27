import { auth, db } from './firebase';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
} from 'firebase/auth';
import { collection, getDocs } from 'firebase/firestore';

// --- Auth Functions ---

// Observe auth state
export const onAuthChange = (callback) => {
  return onAuthStateChanged(auth, callback);
};

// Sign in with email and password
export const signIn = (email, password) => {
  return signInWithEmailAndPassword(auth, email, password);
};

// Sign up with email and password
export const signUp = (email, password) => {
  return createUserWithEmailAndPassword(auth, email, password);
};

// Sign out
export const logOut = () => {
  return signOut(auth);
};

// --- Firestore Functions ---

// Generic function to get a collection
const getCollection = async (collectionName) => {
  const querySnapshot = await getDocs(collection(db, collectionName));
  const data = [];
  querySnapshot.forEach((doc) => {
    data.push({ id: doc.id, ...doc.data() });
  });
  return data;
};


export const getStats = () => getCollection('stats');
export const getUsers = () => getCollection('users');
export const getAuditLogs = () => getCollection('audit-logs');
export const getAccessRequests = () => getCollection('access-requests');
