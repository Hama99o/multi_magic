import { http } from '@/services/http.service';

class CardAPI {
  private basePath = '/api/v1/safezone_app/cards';

  /**
   * Fetch all cards.
   */
  async getCards(search = '', page = 1) {
    const res = await http.get(`${this.basePath}?search=${search}&page=${page}`);
    return res.data;
  }

  /**
   * Fetch a specific card by ID.
   * @param id - Card ID
   */
  async getCard(id: number) {
    const res = await http.get(`${this.basePath}/${id}`);
    return res.data;
  }

  /**
   * Create a new card entry.
   * @param payload - Card data
   */
  async createCard(payload: Record<string, unknown>) {
    const res = await http.post(this.basePath, payload);
    return res.data;
  }

  /**
   * Update an existing card entry by ID.
   * @param id - Card ID
   * @param payload - Updated card data
   */
  async updateCard(id: number, payload: Record<string, unknown>) {
    const res = await http.put(`${this.basePath}/${id}`, payload);
    return res.data;
  }

  /**
   * Delete a card entry by ID.
   * @param id - Card ID
   */
  async deleteCard(id: number) {
    const res = await http.delete(`${this.basePath}/${id}`);
    return res.data;
  }
}

const instance = new CardAPI();
export default instance;
