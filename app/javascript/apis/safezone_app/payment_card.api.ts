import { http } from '@/services/http.service';
import {
  PaymentCard,
  transformPaymentCard,
  transformPaymentCardToSnakeCase,
} from '@/models/payment_card.model';

const API_URL = '/api/v1/safezone_app/payment_cards';

// Fetch all payment cards with optional search parameter
export const fetchPaymentCards = async (search = '', page = 1): Promise<PaymentCard[]> => {
  const response = await http.get(API_URL, { params: { search, page } });
  response.data.payment_cards = response.data.payment_cards.map(transformPaymentCard);
  return response.data;
};

// Fetch a single payment card by ID
export const fetchPaymentCard = async (id: number): Promise<PaymentCard> => {
  const response = await http.get(`${API_URL}/${id}`);
  return transformPaymentCard(response.data);
};

// Create a new payment card
export const createPaymentCard = async (
  paymentCard: Partial<PaymentCard>,
): Promise<PaymentCard> => {
  const response = await http.post(API_URL, transformPaymentCardToSnakeCase(paymentCard));
  return transformPaymentCard(response.data);
};

// Update an existing payment card by ID
export const updatePaymentCard = async (
  id: number,
  paymentCard: Partial<PaymentCard>,
): Promise<PaymentCard> => {
  const response = await http.put(`${API_URL}/${id}`, transformPaymentCardToSnakeCase(paymentCard));
  return transformPaymentCard(response.data);
};

// Delete a payment card by ID
export const deletePaymentCard = async (id: number): Promise<void> => {
  await http.delete(`${API_URL}/${id}`);
};
