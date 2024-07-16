import { createRouter, createWebHistory } from 'vue-router';
import AuthService from '@/services/auth.service';

import { useActionCable } from '@/stores/cable.js';
const NotFound = () => import('@/components/layouts/NotFound.vue');
const Index = () => import('@/views/Home.vue');
const About = () => import('@/views/AboutPage.vue');
const Login = () => import('@/views/LoginPage.vue');
const ForgetPassword = () => import('@/views/ForgetPassword.vue');
const ResetPassword = () => import('@/views/ResetPassword.vue');

const Logout = () => import('@/views/Logout.vue');
const Signup = () => import('@/views/SignupPage.vue');
const Users = () => import('@/views/users/Index.vue');
const UserShow = () => import('@/views/users/Show.vue');
const Ai = () => import('@/views/Ai.vue');
const MessagesPage = () => import('@/views/conversation/Index.vue');
const EditorView = () => import('@/views/EditorView.vue');

// Note App imports
const Notes = () => import('@/views/note_app/notes/Index.vue');
const NoteShow = () => import('@//views/note_app/notes/Show.vue');

// my finance app imports
const ExpenseIndex = () => import('@/views/my_finance_app/expense/Index.vue');
const LoanIndex = () => import('@/views/my_finance_app/loan/Index.vue');

// contact_app
const ContactIndex = () => import('@/views/contact_app/contact/Index.vue');


// blog_app
const ArticleIndex = () => import('@/views/blog_app/article/Index.vue')
const ArticleNew = () => import('@/views/blog_app/article/New.vue')
const ArticleEdit = () => import('@/views/blog_app/article/Edit.vue')
const ArticleShow = () => import('@/views/blog_app/article/Show.vue')

const routes = [
  {
    path: '/',
    name: 'index',
    components: {
      default: Index,
    },
  },
  {
    path: '/editor',
    name: 'editor',
    components: {
      default: EditorView,
    },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not_found',
    components: {
      default: NotFound,
    },
  },
  {
    path: '/login',
    name: 'login',
    components: {
      default: Login,
    },
  },
  {
    path: '/forget_password',
    name: 'forget_password',
    components: {
      default: ForgetPassword,
    },
  },
  {
    path: '/reset_password',
    name: 'reset_password',
    components: {
      default: ResetPassword,
    },
  },
  {
    path: '/signup',
    name: 'signup',
    components: {
      default: Signup,
    },
  },
  {
    path: '/users',
    name: 'users',
    components: {
      default: Users,
    },
  },
  {
    path: '/users/:id',
    name: 'user',
    components: {
      default: UserShow,
    },
  },
  {
    path: '/logout',
    name: 'logout',
    components: {
      default: Logout,
    },
  },
  {
    path: '/conversations',
    name: 'conversations',
    component: MessagesPage,
    // meta: {
    //   requiresAuth: true
    // }
  },
  {
    path: '/note_app/notes', // Main route for listing all notes
    name: 'notes',
    component: Notes, // This component will list all notes
  },
  {
    path: '/note_app/notes/:id', // Route for showing a specific note by its ID
    name: 'note',
    component: NoteShow, // Component that shows a specific note
    props: true, // Pass the 'id' as a prop to the NoteShow component
  },
  {
    path: '/my_finance_app',
    children: [
      {
        path: 'expenses',
        component: ExpenseIndex,
        name: 'expenses',
        children: [],
      },
      {
        path: 'loans',
        component: LoanIndex,
        name: 'loans',
        children: [],
      },
    ],
  },
  {
    path: '/contact_app',
    children: [
      {
        path: 'contacts',
        component: ContactIndex,
        name: 'contacts',
        children: [],
      },
    ],
  },
  {
    path: '/ai',
    name: 'ai',
    components: {
      default: Ai,
    },
  },
  {
    path: '/blog_app',
    children: [
      {
        path: 'articles',
        component: ArticleIndex,
        name: 'articles',
        children: [],
      },
      {
        path: 'articles/new',
        component: ArticleNew,
        name: 'new_article',
        children: [],
      },
      {
        path: 'articles/edit/:id',
        component: ArticleEdit,
        name: 'edit_article',
        children: [],
      },
      {
        path: 'articles/:id',
        component: ArticleShow,
        name: 'article',
        children: [],
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// router.beforeEach(async (to, from, next) => {
//   try {
//     const user = AuthService.getUser();
//     const publicPages = ['/login', '/signup', '/forget_password', '/reset_password', '/'];
//     const authRequired = !publicPages.includes(to.path);

//     if (authRequired && !user) {
//       AuthService.clearCache();
//       next('/login');
//     } else if (to.path === '/login' && user) {
//       next('/');
//     } else {
//       next();
//     }
//   } catch (e) {
//     console.log(e)
//   } finally {
//     const elem = document.querySelector("#mainLoader");
//     elem.style.display = "none";
//   }
// });

router.beforeEach(async (to, from, next) => {
  try {
    // Retrieve the current user
    const user = AuthService.getUser();
    const publicPages = ['login', 'signup', 'forget_password', 'reset_password', 'index', 'articles', 'article'];
    const authRequired = !publicPages.includes(to.name);

    // Extract the user's applications
    const userApplications = user?.applications || [];

    // Define protected routes and their required applications
    const protectedRoutes = {
      '/my_finance_app/expenses': 'MyFinanceApp',
      '/my_finance_app/loans': 'MyFinanceApp',
      '/note_app/notes': 'NoteApp',
      '/users': 'Users',
      // '/users/:id': 'Users',
      // '/users/:id/edit': 'Users',
      // Add other routes as necessary
    };

    // Check if the route is protected and if the user has the required application
    const requiredApp = Object.keys(protectedRoutes).find((route) =>
      to.matched.some((record) => record.path === route),
    );
    const hasAccess = !requiredApp || userApplications.includes(protectedRoutes[requiredApp]);
    const { initActionCable } = useActionCable();
    initActionCable();

    // Handle route navigation logic
    if (authRequired && !user) {
      AuthService.clearCache();
      next('/login');
    } else if (to.path === '/login' && user) {
      next('/');
    } else if (requiredApp && !hasAccess) {
      router.push({ name: 'not_found' });
    } else {
      next();
    }
  } catch (e) {
    console.error('Routing error:', e);
    next(false); // Cancel the navigation in case of an error
  } finally {
    // Hide the main loader after navigation is processed
    const elem = document.querySelector('#mainLoader');
    if (elem) elem.style.display = 'none';
  }
});

export default router;
