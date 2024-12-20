import { defineStore } from 'pinia';
import PasswordManagerAPI from '@/apis/safezone_app/password_manager.api';

export const usePasswordManagerStore = defineStore({
  id: 'password-manager-store',
  state: () => ({
    passwordManagers: [] as Array<Record<string, any>>,
    loading: false,
    error: null as string | null,
  }),
  getters: {
    /**
     * Get a password manager by ID.
     */
    getPasswordManagerById: (state) => (id: number) =>
      state.passwordManagers.find((manager) => manager.id === id),
  },
  actions: {
    /**
     * Fetch all password managers and store them in the state.
     */
    async fetchPasswordManagers() {
      this.loading = true;
      this.error = null;
      try {
        const managers = await PasswordManagerAPI.getPasswordManagers();
        this.passwordManagers = managers;
      } catch (error: unknown) {
        this.error = error.message || 'Failed to fetch password managers.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Create a new password manager entry.
     * @param data - New password manager data
     */
    async createPasswordManager(data: Record<string, any>) {
      this.loading = true;
      this.error = null;
      try {
        const newManager = await PasswordManagerAPI.createPasswordManager(data);
        this.passwordManagers.push(newManager);
      } catch (error: any) {
        this.error = error.message || 'Failed to create password manager.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Update an existing password manager entry by ID.
     * @param id - Password manager ID
     * @param data - Updated password manager data
     */
    async updatePasswordManager(id: number, data: Record<string, any>) {
      this.loading = true;
      this.error = null;
      try {
        const updatedManager = await PasswordManagerAPI.updatePasswordManager(id, data);
        const index = this.passwordManagers.findIndex((manager) => manager.id === id);
        if (index !== -1) {
          this.passwordManagers[index] = updatedManager;
        }
      } catch (error: any) {
        this.error = error.message || 'Failed to update password manager.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Delete a password manager entry by ID.
     * @param id - Password manager ID
     */
    async deletePasswordManager(id: number) {
      this.loading = true;
      this.error = null;
      try {
        await PasswordManagerAPI.deletePasswordManager(id);
        this.passwordManagers = this.passwordManagers.filter((manager) => manager.id !== id);
      } catch (error: any) {
        this.error = error.message || 'Failed to delete password manager.';
      } finally {
        this.loading = false;
      }
    },
  },
});
