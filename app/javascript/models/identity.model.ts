export interface Identity {
  id: number;
  type: string;
  documentNumber: string;
  issuedAt: string;
  expiresAt: string;
  note: Record<string, any>;
  userId: number;
  createdAt: string;
  updatedAt: string;
}

// Convert snake_case keys from Rails API to camelCase keys for the frontend
export const transformIdentity = (data: any): Identity => {
  return {
    id: data.id,
    type: data.type,
    documentNumber: data.document_number,
    issuedAt: data.issued_at,
    expiresAt: data.expires_at,
    note: data.note,
    userId: data.user_id,
    createdAt: data.created_at,
    updatedAt: data.updated_at,
  };
};

// Convert camelCase keys from frontend to snake_case keys for Rails API
export const transformIdentityToSnakeCase = (data: Partial<Identity>): any => {
  return {
    id: data.id,
    type: data.type,
    document_number: data.documentNumber,
    issued_at: data.issuedAt,
    expires_at: data.expiresAt,
    note: data.note,
    user_id: data.userId,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
};
