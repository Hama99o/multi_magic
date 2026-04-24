export interface PaymentCard {
  id: number;
  name: string;
  cardType: number;
  cardNumber: string;
  cvv: string;
  expiryDate: string;
  status: number;
  note: string;
  code: string;
  ownerId: number;
  createdAt: string;
  updatedAt: string;
}

// Convert snake_case keys from Rails API to camelCase keys for the frontend
export const transformPaymentCard = (data: any): PaymentCard => {
  return {
    id: data.id,
    name: data.name,
    cardType: data.card_type,
    cardNumber: data.card_number,
    cvv: data.cvv,
    expiryDate: data.expiry_date,
    status: data.status,
    note: data.note,
    code: data.code,
    ownerId: data.owner_id,
    createdAt: data.created_at,
    updatedAt: data.updated_at,
  };
};

// Convert camelCase keys from frontend to snake_case keys for Rails API
export const transformPaymentCardToSnakeCase = (data: Partial<PaymentCard>): any => {
  return {
    id: data.id,
    name: data.name,
    card_type: data.cardType,
    card_number: data.cardNumber,
    cvv: data.cvv,
    expiry_date: data.expiryDate,
    status: data.status,
    note: data.note,
    code: data.code,
    owner_id: data.ownerId,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
};
