// functions/src/index.ts

// --- V2 IMPORTS: We import specific functions, not the whole library ---
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {defineString} from "firebase-functions/params";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();

// --- V2 PARAMETERS: Define the secret key parameter ---
const stripeSecretKey = defineString("STRIPE_SECRETKEY");

const stripe = new Stripe(stripeSecretKey.value(), {
  apiVersion: "2024-04-10",
});


/**
 * This is a v2 Cloud Function to create a Stripe Payment Intent.
 */
export const createStripePaymentIntent = onCall(
  {region: "asia-southeast1"},
  async (request) => {
    // In v2, authentication info is in request.auth
    if (!request.auth) {
      logger.error("User is not authenticated.");
      throw new HttpsError(
        "unauthenticated",
        "You must be logged in to make a payment."
      );
    }

    // In v2, data sent from the app is in request.data
    const amount = request.data.amount as number;
    const currency = request.data.currency as string;

    if (!amount || !currency) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with 'amount' and 'currency'."
      );
    }

    logger.info(`PaymentInt ${amount} ${currency} user ${request.auth.uid}`);

    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount,
        currency: currency,
        automatic_payment_methods: {enabled: true},
      });

      return {
        clientSecret: paymentIntent.client_secret,
      };
    } catch (error) {
      logger.error("Stripe Payment Intent creation failed", error);
      throw new HttpsError(
        "internal",
        "Failed to create Stripe Payment Intent."
      );
    }
  });
