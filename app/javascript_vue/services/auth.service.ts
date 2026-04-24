import { storeToRefs } from 'pinia';
import { http, setHTTPHeader } from './http.service';
import { IUserLogin, IRegisterUser } from '@/types/general';
import { login, logout, register } from '@/apis/auth.api';
import { useUserStore } from '@/stores/user.store';

class AuthService {
  async login(user: IUserLogin) {
    return login(user).then((response) => {
      if (response.headers.authorization) {
        const token = response.headers.authorization;
        localStorage.setItem('user', JSON.stringify(response.data));
        localStorage.setItem('token', token);
        setHTTPHeader({ Authorization: token });
      }

      return response.data;
    });
  }

  async logout() {
    return logout().finally(() => {
      delete http.defaults.headers.common['Authorization'];
      this.clearCacheAndRedirect();
    });
  }

  async register(user: IRegisterUser) {
    return register(user);
  }

  clearCache(): void {
    localStorage.removeItem('user');
    localStorage.removeItem('token');
  }

  clearCacheAndRedirect(): void {
    this.clearCache();
    // location.href = '/';
  }

  isSuperAdmin() {
    if (this.getUser()) {
      const { currentUser } = storeToRefs(useUserStore());
      return currentUser?.value?.access_level === 'super_admin';
    }
  }

  getUser() {
    const user = localStorage.getItem('user');

    if (user) {
      try {
        return JSON.parse(user);
      } catch {
        return null;
      }
    }

    return null;
  }

  getToken() {
    return localStorage.getItem('token');
  }
}

const instance = new AuthService();

export default instance;
