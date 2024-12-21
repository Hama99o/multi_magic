import { defineStore } from 'pinia';
import PasswordAPI from '@/apis/safezone_app/password.api';

export const usepasswordstore = defineStore({
  id: 'password-store',
  state: () => ({
    passwords: [] as Array<Record<string, any>>,
    loading: false,
    error: null as string | null,
  }),
  getters: {
    /**
     * Get a passwords by ID.
     */
    getPasswordById: (state) => (id: number) =>
      state.passwords.find((Password) => Password.id === id),
  },
  actions: {
    /**
     * Fetch all passwords and store them in the state.
     */
    async fetchpasswords() {
      this.loading = true;
      this.error = null;
      try {
        console.log('hiii')
        const data = await PasswordAPI.getPasswords();
        this.passwords = data;
      } catch (error: unknown) {
        this.error = error.message || 'Failed to fetch passwords.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Create a new passwords entry.
     * @param data - New passwords data
     */
    async createPassword(data: Record<string, any>) {
      this.loading = true;
      this.error = null;
      try {
        const newPassword = await PasswordAPI.createPassword(data);
        this.passwords.push(newPassword);
      } catch (error: any) {
        this.error = error.message || 'Failed to create passwords.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Update an existing passwords entry by ID.
     * @param id - passwords ID
     * @param data - Updated passwords data
     */
    async updatePassword(id: number, data: Record<string, any>) {
      this.loading = true;
      this.error = null;
      try {
        const updatedPassword = await PasswordAPI.updatePassword(id, data);
        const index = this.passwords.findIndex((Password) => Password.id === id);
        if (index !== -1) {
          this.passwords[index] = updatedPassword;
        }
      } catch (error: any) {
        this.error = error.message || 'Failed to update passwords.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Delete a passwords entry by ID.
     * @param id - passwords ID
     */
    async deletePassword(id: number) {
      this.loading = true;
      this.error = null;
      try {
        await PasswordAPI.deletePassword(id);
        this.passwords = this.passwords.filter((Password) => Password.id !== id);
      } catch (error: any) {
        this.error = error.message || 'Failed to delete passwords.';
      } finally {
        this.loading = false;
      }
    },
  },
});
