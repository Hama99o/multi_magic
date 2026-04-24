export interface IUserLogin {
  email: string
  password: string
}

export interface IRegisterUser {
  email: string
  password: string
  password_confirmation: string
  firstname: string
  lastname: string
  birth_date?: string
  agreed_to_terms: boolean
}

export interface ICurrentUser {
  id: number
  email: string
  firstname: string
  lastname: string
  theme?: string
  applications: string[]
  access_level: string
  avatar_url?: string
}
