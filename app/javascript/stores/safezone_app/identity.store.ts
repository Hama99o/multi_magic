import { defineStore } from 'pinia';
import {
  fetchIdentities,
  fetchIdentity,
  createIdentity,
  updateIdentity,
  deleteIdentity,
} from '@/apis/safezone_app/identity.api';
import { Identity } from '@/models/identity.model';

export const useIdentityStore = defineStore({
  id: 'identity-store',
  state: () => ({
    identities: [] as Identity[],
    newIdentity: {
      id: null as number | null,
      type: '',
      documentNumber: '',
      issuedAt: '',
      expiresAt: '',
      note: '',
      userId: 0,
      createdAt: '',
      updatedAt: '',
    } as Partial<Identity>,
    pagination: {},
    search: '',
    page: 1,
    totalPages: 0,
    loading: false,
    error: null as string | null,
  }),
  getters: {
    /**
     * Get an identity by ID.
     */
    getIdentityById: (state) => (id: number) =>
      state.identities.find((identity) => identity.id === id),
  },
  actions: {
    /**
     * Fetch all identities and store them in the state.
     */
    async fetchIdentities() {
      this.loading = true;
      this.error = null;
      try {
        const res = await fetchIdentities(this.search, this.page);
        this.identities = res.identities;
        this.page = res.meta.pagy.page
        this.totalPages = res.meta.pagy.pages
        this.pagination = {
          current_page: res.meta.pagy.page,
          total_pages: res.meta.pagy.pages,
          total_items: res.meta.total_count,
        };
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to fetch identities.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Fetch more identities for infinite scroll.
     */
    async fetchMoreIdentities() {
      const res = await fetchIdentities(this.search, this.page);
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;{}
      return res.identities;
    },

    /**
     * Fetch a single identity by ID.
     */
    async fetchIdentity(id: number) {
      this.loading = true;
      this.error = null;
      try {
        const identity = await fetchIdentity(id);
        return identity;
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to fetch identity.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Create a new identity entry.
     * @param data - New identity data
     */
    async createIdentity(data: Partial<Identity>) {
      this.loading = true;
      this.error = null;
      try {
        await createIdentity(data);
        await this.fetchIdentities();
        this.newIdentity = {
          id: null,
          type: '',
          documentNumber: '',
          issuedAt: '',
          expiresAt: '',
          note: '',
          userId: 0,
          createdAt: '',
          updatedAt: '',
        };
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to create identity.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Update an existing identity entry by ID.
     * @param id - Identity ID
     * @param data - Updated identity data
     */
    async updateIdentity(id: number, data: Partial<Identity>) {
      this.loading = true;
      this.error = null;
      try {
        const updatedIdentity = await updateIdentity(id, data);
        const index = this.identities.findIndex((identity) => identity.id === id);
        if (index !== -1) {
          this.identities[index] = updatedIdentity;
        }
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to update identity.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Delete an identity entry by ID.
     * @param id - Identity ID
     */
    async deleteIdentity(id: number) {
      this.loading = true;
      this.error = null;
      this.page = 1;
      try {
        await deleteIdentity(id);
        await this.fetchIdentities();
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to delete identity.';
      } finally {
        this.loading = false;
      }
    },
  },
});
