import { http } from '@/services/http.service';

class PasswordManagerAPI {
  private basePath = '/api/v1/safezone_app/password_managers';

  /**
   * Fetch all password managers.
   */
  async getPasswordManagers() {
    const res = await http.get(this.basePath);
    return res.data;
  }

  /**
   * Fetch a specific password manager by ID.
   * @param id - Password manager ID
   */
  async getPasswordManager(id: number) {
    const res = await http.get(`${this.basePath}/${id}`);
    return res.data;
  }

  /**
   * Create a new password manager entry.
   * @param payload - Password manager data
   */
  async createPasswordManager(payload: Record<string, unknown>) {
    const res = await http.post(this.basePath, payload);
    return res.data;
  }

  /**
   * Update an existing password manager entry by ID.
   * @param id - Password manager ID
   * @param payload - Updated password manager data
   */
  async updatePasswordManager(id: number, payload: Record<string, unknown>) {
    const res = await http.put(`${this.basePath}/${id}`, payload);
    return res.data;
  }

  /**
   * Delete a password manager entry by ID.
   * @param id - Password manager ID
   */
  async deletePasswordManager(id: number) {
    const res = await http.delete(`${this.basePath}/${id}`);
    return res.data;
  }
}

const instance = new PasswordManagerAPI();
export default instance;
