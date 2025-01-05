import { defineStore } from 'pinia';
import {
  fetchPaymentCards,
  fetchPaymentCard,
  createPaymentCard,
  updatePaymentCard,
  deletePaymentCard,
} from '@/apis/safezone_app/payment_card.api';
import { PaymentCard } from '@/models/payment_card.model';

export const usePaymentCardStore = defineStore({
  id: 'payment-card-store',
  state: () => ({
    paymentCards: [] as PaymentCard[],
    newPaymentCard: {
      id: null as number | null,
      name: '',
      cardType: 'credit_card',
      cardNumber: '',
      cvv: '',
      expiryDate: '',
      status: 0,
      note: '',
      code: '',
      ownerId: 0,
      createdAt: '',
      updatedAt: '',
    } as Partial<PaymentCard>,
    pagination: {},
    search: '',
    page: 1,
    totalPages: 0,
    loading: false,
    error: null as string | null,
  }),
  getters: {
    /**
     * Get a payment card by ID.
     */
    getPaymentCardById: (state) => (id: number) =>
      state.paymentCards.find((paymentCard) => paymentCard.id === id),
  },
  actions: {
    /**
     * Fetch all payment cards and store them in the state.
     */
    async fetchPaymentCards() {
      this.loading = true;
      this.error = null;
      try {
        const res = await fetchPaymentCards(this.search, this.page);
        this.paymentCards = res.payment_cards;
        this.page = res.meta.pagy.page
        this.totalPages = res.meta.pagy.pages
        this.pagination = {
          current_page: res.meta.pagy.page,
          total_pages: res.meta.pagy.pages,
          total_items: res.meta.total_count,
        };
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to fetch payment cards.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Fetch more payment cards for infinite scroll.
     */
    async fetchMorePaymentCards() {
      const res = await fetchPaymentCards(this.search, this.page);
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
      return res.payment_cards;
    },

    /**
     * Fetch a single payment card by ID.
     */
    async fetchPaymentCard(id: number) {
      this.loading = true;
      this.error = null;
      try {
        const paymentCard = await fetchPaymentCard(id);
        return paymentCard;
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to fetch payment card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Create a new payment card entry.
     * @param data - New payment card data
     */
    async createPaymentCard(data: Partial<PaymentCard>) {
      this.loading = true;
      this.error = null;
      try {
        await createPaymentCard(data);
        await this.fetchPaymentCards();
        this.newPaymentCard = {
          id: null,
          name: '',
          cardType: 'credit_card',
          cardNumber: '',
          cvv: '',
          expiryDate: '',
          status: 0,
          note: '',
          code: '',
          ownerId: 0,
          createdAt: '',
          updatedAt: '',
        };
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to create payment card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Update an existing payment card entry by ID.
     * @param id - Payment card ID
     * @param data - Updated payment card data
     */
    async updatePaymentCard(id: number, data: Partial<PaymentCard>) {
      this.loading = true;
      this.error = null;
      try {
        const updatedCard = await updatePaymentCard(id, data);
        const index = this.paymentCards.findIndex((paymentCard) => paymentCard.id === id);
        if (index !== -1) {
          this.paymentCards[index] = updatedCard;
        }
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to update payment card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Delete a payment card entry by ID.
     * @param id - Payment card ID
     */
    async deletePaymentCard(id: number) {
      this.loading = true;
      this.error = null;
      this.page = 1;
      try {
        await deletePaymentCard(id);
        await this.fetchPaymentCards();
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to delete payment card.';
      } finally {
        this.loading = false;
      }
    },
  },
});
