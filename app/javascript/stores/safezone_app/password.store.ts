import { defineStore } from 'pinia';
import PasswordAPI from '@/apis/safezone_app/password.api';

export const usepasswordstore = defineStore({
  id: 'password-store',
  state: () => ({
    passwords: [] as Array<Record<string, any>>,
    newPassword: {
      id: null,
      title: '',
      username: '',
      email: '',
      password: '',
      link: '',
      note: '',
    },
    pagination: {},
    search: '',
    page: 1,
    totalPages: 0,
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
        const res = await PasswordAPI.getPasswords(this.search, this.page);
        this.passwords = res.passwords;
        this.page = res.meta.pagy.page
        this.totalPages = res.meta.pagy.pages
        this.pagination = {
          current_page: res.meta.pagy.page,
          total_pages: res.meta.pagy.pages,
          total_items: res.meta.total_count,
        };
      } catch (error: unknown) {
        this.error = error.message || 'Failed to fetch passwords.';
      } finally {
        this.loading = false;
      }
    },

    async fetchMorePasswords() {
      const res = await PasswordAPI.getPasswords(this.search, this.page);
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
      return res.passwords;
    },

    /**
     * Create a new passwords entry.
     * @param data - New passwords data
     */
    async createPassword(data = {}) {
      this.loading = true;
      this.error = null;
      try {
        await PasswordAPI.createPassword({ password: data });
        this.search = '';
        this.page = 1;
        await this.fetchpasswords();
        this.newPassword = {
          id: null,
          title: '',
          username: '',
          email: '',
          password: '',
          link: '',
          note: '',
        };
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
        const updatedPassword = await PasswordAPI.updatePassword(id, { password: data });
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
