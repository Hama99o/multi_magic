import type { AxiosResponse } from 'axios';
import { http } from '@/services/http.service';

export const getData = (title: string): Promise<AxiosResponse> => {
  // Use URLSearchParams to format the query string correctly
  const params = new URLSearchParams({ title });

  return http.get(`api/v1/ai/show?${params}`);
};
