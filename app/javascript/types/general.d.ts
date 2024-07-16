export interface IUserLogin {
  firstname: string,
  lastname: string,
  birth_date: string,
  email: string,
  password: string,
  password_confirmation: string,
  agreed_to_terms: boolean
}

export interface IRegisterUser extends IUserLogin {
  password_confirmation: string;
}

export interface ICurrentUser {
  id: number;
}

export interface IUserForgotPassword {
  email: string;
}

export interface IUserResetPassword {
  password: string;
  confirmPassword: string;
}