import { defineStore } from 'pinia';
import CardAPI from '@/apis/safezone_app/card.api';

export const useCardStore = defineStore({
  id: 'card-store',
  state: () => ({
    cards: [] as Array<Record<string, any>>,
    newCard: {
      id: null,
      name: '',
      card_type: '',
      identifier: '',
      expiry_date: '',
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
     * Get a card by ID.
     */
    getCardById: (state) => (id: number) =>
      state.cards.find((card) => card.id === id),
  },
  actions: {
    /**
     * Fetch all cards and store them in the state.
     */
    async fetchCards() {
      this.loading = true;
      this.error = null;
      try {
        const res = await CardAPI.getCards(this.search, this.page);
        this.cards = res.cards;
        this.page = res.meta.pagy.page;
        this.totalPages = res.meta.pagy.pages;
        this.pagination = {
          current_page: res.meta.pagy.page,
          total_pages: res.meta.pagy.pages,
          total_items: res.meta.total_count,
        };
      } catch (error: any) {
        this.error = error.message || 'Failed to fetch cards.';
      } finally {
        this.loading = false;
      }
    },

    async fetchMoreCards() {
      const res = await CardAPI.getCards(this.search, this.page);
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
      return res.cards;
    },

    /**
     * Create a new card entry.
     * @param data - New card data
     */
    async createCard(data = {}) {
      this.loading = true;
      this.error = null;
      try {
        await CardAPI.createCard({ card: data });
        this.search = '';
        this.page = 1;
        await this.fetchCards();
        this.newCard = {
          id: null,
          name: '',
          card_type: '',
          identifier: '',
          expiry_date: '',
          note: '',
        };
      } catch (error: any) {
        this.error = error.message || 'Failed to create card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Update an existing card entry by ID.
     * @param id - Card ID
     * @param data - Updated card data
     */
    async updateCard(id: number, data: Record<string, any>) {
      this.loading = true;
      this.error = null;
      try {
        const updatedCard = await CardAPI.updateCard(id, { card: data });
        const index = this.cards.findIndex((card) => card.id === id);
        if (index !== -1) {
          this.cards[index] = updatedCard;
        }
      } catch (error: any) {
        this.error = error.message || 'Failed to update card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Delete a card entry by ID.
     * @param id - Card ID
     */
    async deleteCard(id: number) {
      this.loading = true;
      this.error = null;
      try {
        await CardAPI.deleteCard(id);
        this.cards = this.cards.filter((card) => card.id !== id);
      } catch (error: any) {
        this.error = error.message || 'Failed to delete card.';
      } finally {
        this.loading = false;
      }
    },
  },
});
