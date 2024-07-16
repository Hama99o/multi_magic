import { http } from '@/services/http.service';

class ImageAPI {
  async createImage(data: string) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/images`, data, { headers });
    return res.data?.url;
  }
}

const instance = new ImageAPI();

export default instance;
