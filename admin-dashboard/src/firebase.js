// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDo-oKdImoEqPzFT3vwGTJ5j6x74bXcWjc",
  authDomain: "atkans-med.firebaseapp.com",
  projectId: "atkans-med",
  storageBucket: "atkans-med.firebasestorage.app",
  messagingSenderId: "123456789",
  appId: "1:339895708806:android:8700b511bfbd54cae3b507"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

export { auth, db };
