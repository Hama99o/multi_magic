import { http } from '@/services/http.service';

class PasswordAPI {
  private basePath = '/api/v1/safezone_app/passwords';

  /**
   * Fetch all passwords.
   */
  async getPasswords(search = '', page = 1) {
    const res = await http.get(`${this.basePath}?search=${search}&page=${page}`);
    return res.data;
  }

  /**
   * Fetch a specific passwords by ID.
   * @param id - passwords ID
   */
  async getPassword(id: number) {
    const res = await http.get(`${this.basePath}/${id}`);
    return res.data;
  }

  /**
   * Create a new passwords entry.
   * @param payload - passwords data
   */
  async createPassword(payload: Record<string, unknown>) {
    const res = await http.post(this.basePath, payload);
    return res.data;
  }

  /**
   * Update an existing passwords entry by ID.
   * @param id - passwords ID
   * @param payload - Updated passwords data
   */
  async updatePassword(id: number, payload: Record<string, unknown>) {
    const res = await http.put(`${this.basePath}/${id}`, payload);
    return res.data;
  }

  /**
   * Delete a passwords entry by ID.
   * @param id - passwords ID
   */
  async deletePassword(id: number) {
    const res = await http.delete(`${this.basePath}/${id}`);
    return res.data;
  }
}

const instance = new PasswordAPI();
export default instance;
