import { Routes, Route, Navigate } from 'react-router-dom'
import { lazy, Suspense } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { ProtectedRoute } from '@/components/routing/ProtectedRoute'
import { MainLayout } from '@/components/layout/MainLayout'

const Home = lazy(() => import('@/pages/Home'))
const Login = lazy(() => import('@/pages/auth/Login'))
const Signup = lazy(() => import('@/pages/auth/Signup'))
const ForgotPassword = lazy(() => import('@/pages/auth/ForgotPassword'))
const ResetPassword = lazy(() => import('@/pages/auth/ResetPassword'))
const Logout = lazy(() => import('@/pages/auth/Logout'))
const NotFound = lazy(() => import('@/components/layout/NotFound'))

function LoadingFallback() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
    </div>
  )
}

export function AppRoutes() {
  const { isAuthenticated } = useAuth()

  return (
    <Suspense fallback={<LoadingFallback />}>
      <Routes>
        {/* Auth routes — redirect to home if already logged in */}
        <Route
          path="/login"
          element={isAuthenticated ? <Navigate to="/" replace /> : <Login />}
        />
        <Route
          path="/signup"
          element={isAuthenticated ? <Navigate to="/" replace /> : <Signup />}
        />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/reset-password" element={<ResetPassword />} />
        <Route path="/logout" element={<Logout />} />

        {/* Main layout wraps all app routes */}
        <Route element={<MainLayout />}>
          <Route index element={<Home />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </Suspense>
  )
}
