import { http } from '@/services/http.service';
import {
  Identity,
  transformIdentity,
  transformIdentityToSnakeCase,
} from '@/models/identity.model';

const API_URL = '/api/v1/safezone_app/identities';

// Fetch all identities with optional search parameter
export const fetchIdentities = async (search = '', page = 1): Promise<Identity[]> => {
  const response = await http.get(API_URL, { params: { search, page } });
  response.data.identities = response.data.identities.map(transformIdentity);
  return response.data;
};

// Fetch a single identity by ID
export const fetchIdentity = async (id: number): Promise<Identity> => {
  const response = await http.get(`${API_URL}/${id}`);
  return transformIdentity(response.data);
};

// Create a new identity
export const createIdentity = async (
  identity: Partial<Identity>,
): Promise<Identity> => {
  const response = await http.post(API_URL, transformIdentityToSnakeCase(identity));
  return transformIdentity(response.data);
};

// Update an existing identity by ID
export const updateIdentity = async (
  id: number,
  identity: Partial<Identity>,
): Promise<Identity> => {
  const response = await http.put(`${API_URL}/${id}`, transformIdentityToSnakeCase(identity));
  return transformIdentity(response.data);
};

// Delete an identity by ID
export const deleteIdentity = async (id: number): Promise<void> => {
  await http.delete(`${API_URL}/${id}`);
};
