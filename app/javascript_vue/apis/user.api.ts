import { useRouter } from 'vue-router';
import { http } from '@/services/http.service';
import AuthService from '@/services/auth.service';

class UserAPI {
  async fetchUsers(page = 1, search = '') {
    try {
      const res = await http.get(`/api/v1/users?page=${page}&search=${search}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async fetcGlobalhUsers(page = 1, search = '') {
    try {
      const res = await http.get(`/api/v1/users/global_users?page=${page}&search=${search}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async fetchUser(id: number) {
    try {
      const res = await http.get(`/api/v1/users/${id}`);
      return res.data;
    } catch (error) {
      if (error?.error === 'Signature has expired') {
        const router = useRouter();
        AuthService.logout().then(() => {
          router.push({ name: 'signin' });
        });
      }
    }
  }
  async fetchFollowing(id: number, page = 1, search = '') {
    try {
      const res = await http.get(`/api/v1/users/${id}/following?page=${page}&search=${search}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async fetchFollowers(id: number, page = 1, search = '') {
    try {
      const res = await http.get(`/api/v1/users/${id}/followers?page=${page}&search=${search}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async fetchCurrentUser(id: number) {
    try {
      const res = await http.get('/api/v1/users/connected_user');
      return res.data;
    } catch (error) {
      if (error?.error === 'Signature has expired') {
        const router = useRouter();
        AuthService.logout().then(() => {
          router.push({ name: 'signin' });
        });
      }
    }
  }
  async deleteUserAvatar(id: number, image_type_name: 'photo') {
    try {
      const headers = { 'Content-Type': 'multipart/form-data' };
      const res = await http.delete(`/api/v1/users/${id}/destroy_avatar?image_type_name=${image_type_name}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async updateUser(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/users/${id}`, data, { headers });
    return res.data;
  }
  async forgotPassword(email: string) {
    return http.put('/api/v1/users/reset_password', email);
  }
  async resetPassword(data: {}) {
    return http.put('api/v1/users/reset_password_confirmation', data);
  }
  async changePassword(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    return http.put(`/api/v1/users/${id}/change_password`, data, { headers });

  }
  async impersonateUser(id: number) {
    try {
      const res = await http.post(`/api/v1/impersonate/start_impersonating`, {
        id: id,
      });
      if (res?.data?.user) {
        localStorage.setItem('user', JSON.stringify(res?.data?.user));
      }
      return res?.data;
    } catch (error) {
      return error;
    }
  }
  async stopImpersonating() {
    try {
      const res = await http.post(`/api/v1/impersonate/stop_impersonating`);
      if (res?.data?.user) {
        localStorage.setItem('user', JSON.stringify(res?.data?.user));
      }
      return res?.data;
    } catch (error) {
      return error;
    }
  }
  async isImpersonating() {
    try {
      const res = await http.get(`/api/v1/impersonate/is_impersonating`)
      return res?.data?.isImpersonating;
    } catch (error) {
      console.log(error);
    }
  }
}

const instance = new UserAPI();

export default instance;
