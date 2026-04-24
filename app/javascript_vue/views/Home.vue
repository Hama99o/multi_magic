<template>
  <v-app>
    <v-main>
      <!-- Hero Section -->
      <section class="py-md-16 py-12">
        <v-container>
          <v-row align="center" justify="center">
            <v-col cols="12" lg="10" xl="8">
              <div class="text-center">
                <!-- Main Headline -->
                <div class="mb-6">
                  <h1 class="text-h2 text-md-h1 font-weight-bold mb-4 text-primary">Multi Magic</h1>
                  <p class="text-h5 text-md-h4 font-weight-medium text-medium-emphasis">
                    Your Complete Productivity Suite
                  </p>
                </div>

                <!-- Subtitle -->
                <p
                  class="text-body-1 text-md-h6 text-medium-emphasis mx-auto mb-6"
                  style="max-width: 600px"
                >
                  Streamline your workflow with integrated tools for notes, contacts, blogging,
                  password management, and finance tracking.
                </p>

                <!-- Action Buttons -->
                <div class="d-flex flex-column flex-sm-row align-center ga-3 mb-6 justify-center">
                  <v-btn
                    v-if="!currentUser"
                    color="primary"
                    size="large"
                    :to="{ name: 'signup' }"
                    prepend-icon="mdi-rocket-launch"
                    class="font-weight-medium"
                  >
                    Get Started Free
                  </v-btn>
                  <v-btn
                    v-if="!currentUser"
                    variant="outlined"
                    color="primary"
                    size="large"
                    :to="{ name: 'login' }"
                    prepend-icon="mdi-login"
                  >
                    Sign In
                  </v-btn>
                  <v-btn
                    v-if="currentUser"
                    color="primary"
                    size="large"
                    :to="{ name: 'notes', query: { page: 'all_notes' } }"
                    prepend-icon="mdi-view-dashboard"
                    class="font-weight-medium"
                  >
                    Go to Dashboard
                  </v-btn>
                </div>

                <!-- Feature Highlights -->
                <div class="d-flex ga-4 text-medium-emphasis flex-wrap justify-center">
                  <div class="d-flex align-center ga-2">
                    <v-icon color="success" size="small">mdi-check-circle</v-icon>
                    <span class="text-body-2">Free to Start</span>
                  </div>
                  <div class="d-flex align-center ga-2">
                    <v-icon color="success" size="small">mdi-check-circle</v-icon>
                    <span class="text-body-2">Secure & Private</span>
                  </div>
                  <div class="d-flex align-center ga-2">
                    <v-icon color="success" size="small">mdi-check-circle</v-icon>
                    <span class="text-body-2">Works Everywhere</span>
                  </div>
                </div>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Apps Grid -->
      <section class="py-12">
        <v-container>
          <div class="mb-8 text-center">
            <h2 class="text-h4 font-weight-bold mb-3 text-primary">Our Applications</h2>
            <p class="text-body-1 text-medium-emphasis mx-auto" style="max-width: 500px">
              Integrated tools designed to enhance your productivity
            </p>
          </div>

          <v-row class="justify-center">
            <v-col v-for="app in apps" :key="app.title" cols="12" sm="6" lg="4" class="d-flex">
              <v-card
                class="flex-grow-1 d-flex flex-column"
                elevation="2"
                hover
                :ripple="false"
                style="cursor: pointer"
                @click="navigateToApp(app.route)"
              >
                <v-card-title class="d-flex align-center ga-3 pa-4">
                  <v-avatar :color="app.color" size="40">
                    <v-icon :icon="app.icon" color="white" size="20" />
                  </v-avatar>
                  <div>
                    <div class="text-h6 font-weight-bold">{{ app.title }}</div>
                    <div class="text-caption text-medium-emphasis">
                      {{ getAppSubtitle(app.title) }}
                    </div>
                  </div>
                </v-card-title>

                <v-card-text class="flex-grow-1 pa-4 pt-0">
                  <p class="text-body-2 text-medium-emphasis mb-3">{{ app.description }}</p>
                  <v-list class="pa-0" density="compact">
                    <v-list-item
                      v-for="feature in app.features.slice(0, 2)"
                      :key="feature"
                      class="px-0"
                      style="min-height: 28px"
                    >
                      <template #prepend>
                        <v-icon icon="mdi-check" color="success" size="14" class="mr-2" />
                      </template>
                      <v-list-item-title class="text-body-2">{{ feature }}</v-list-item-title>
                    </v-list-item>
                  </v-list>
                </v-card-text>

                <v-card-actions class="pa-4 pt-0">
                  <v-btn
                    :color="app.color"
                    variant="flat"
                    block
                    :prepend-icon="app.icon"
                    class="font-weight-medium"
                  >
                    Open {{ app.title }}
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Features Section -->
      <section class="py-12">
        <v-container>
          <div class="mb-8 text-center">
            <h2 class="text-h4 font-weight-bold mb-3 text-primary">Why Choose Multi Magic?</h2>
            <p class="text-body-1 text-medium-emphasis mx-auto" style="max-width: 500px">
              Built with modern technologies for security, performance, and seamless integration
            </p>
          </div>

          <v-row class="justify-center">
            <v-col v-for="feature in features" :key="feature.title" cols="12" md="4" class="d-flex">
              <div class="flex-grow-1 text-center">
                <div class="mb-4">
                  <v-avatar :color="feature.color" size="64" class="mb-3" elevation="1">
                    <v-icon :icon="feature.icon" color="white" size="32" />
                  </v-avatar>
                </div>
                <h3 class="text-h6 font-weight-bold mb-2 text-primary">
                  {{ feature.title }}
                </h3>
                <p class="text-body-2 text-medium-emphasis">
                  {{ feature.description }}
                </p>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Stats Section -->
      <section class="py-8">
        <v-container>
          <div class="mb-6 text-center">
            <h2 class="text-h5 font-weight-bold mb-2 text-primary">Trusted Worldwide</h2>
          </div>
          <v-row class="justify-center">
            <v-col v-for="stat in stats" :key="stat.label" cols="6" md="3" class="text-center">
              <div class="text-h4 font-weight-bold mb-1 text-primary">
                {{ stat.value }}
              </div>
              <div class="text-body-2 text-medium-emphasis font-weight-medium">
                {{ stat.label }}
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Footer -->
      <section class="mt-8 py-8">
        <v-container>
          <v-row>
            <v-col cols="12" md="4" class="mb-md-0 mb-6">
              <div class="d-flex align-center ga-2 mb-4">
                <v-icon size="32" color="primary">mdi-star-four-points</v-icon>
                <h3 class="text-h5 font-weight-bold text-primary">Multi Magic</h3>
              </div>
              <p class="text-body-1 text-medium-emphasis mb-4" style="line-height: 1.6">
                Your complete productivity solution for notes, contacts, blogs, passwords, and
                finances - all in one secure platform.
              </p>
              <div class="d-flex ga-2">
                <v-btn
                  icon="mdi-gitlab"
                  variant="text"
                  href="https://gitlab.com/Hama99o"
                  target="_blank"
                  size="small"
                  color="primary"
                />
                <v-btn
                  icon="mdi-github"
                  variant="text"
                  href="https://github.com/Hama99o"
                  target="_blank"
                  size="small"
                  color="primary"
                />
                <v-btn
                  icon="mdi-linkedin"
                  variant="text"
                  href="https://www.linkedin.com/in/hammayoun-safi-2916581bb/"
                  target="_blank"
                  size="small"
                  color="primary"
                />
              </div>
            </v-col>

            <v-col cols="12" md="4" class="mb-md-0 mb-6">
              <h3 class="text-h6 font-weight-bold mb-4 text-primary">Applications</h3>
              <v-list color="transparent" class="pa-2" density="compact">
                <v-list-item
                  v-for="app in apps"
                  :key="app.title"
                  :to="app.route"
                  class="text-medium-emphasis px-0"
                  :prepend-icon="app.icon"
                >
                  {{ app.title }}
                </v-list-item>
              </v-list>
            </v-col>

            <v-col cols="12" md="4">
              <h3 class="text-h6 font-weight-bold mb-4 text-primary">Support & Legal</h3>
              <v-list color="transparent" class="pa-2" density="compact">
                <v-list-item
                  to="/about"
                  class="text-medium-emphasis px-0"
                  prepend-icon="mdi-information-outline"
                >
                  About Us
                </v-list-item>
                <v-list-item
                  to="/contact"
                  class="text-medium-emphasis px-0"
                  prepend-icon="mdi-help-circle-outline"
                >
                  Contact Support
                </v-list-item>
                <v-list-item
                  to="/policy"
                  class="text-medium-emphasis px-0"
                  prepend-icon="mdi-shield-check-outline"
                >
                  Privacy Policy
                </v-list-item>
                <v-list-item
                  to="/policy"
                  class="text-medium-emphasis px-0"
                  prepend-icon="mdi-file-document-outline"
                >
                  Terms of Service
                </v-list-item>
              </v-list>
            </v-col>
          </v-row>

          <v-divider class="my-6 opacity-30" />

          <div class="text-medium-emphasis text-center">
            <p class="text-body-2">
              © {{ new Date().getFullYear() }} Multi Magic. All rights reserved.
              <span class="d-inline-block">Built with ❤️ for productivity.</span>
            </p>
          </div>
        </v-container>
      </section>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user.store';

const router = useRouter();
const { currentUser } = storeToRefs(useUserStore());

// Navigation helper
const navigateToApp = (route: string) => {
  router.push(route);
};

// App subtitle helper
const getAppSubtitle = (title: string): string => {
  const subtitles = {
    Notes: 'Organize & Create',
    'Todo Lists': 'Get Things Done',
    Contacts: 'Manage Relationships',
    Blog: 'Share Stories',
    'Password Manager': 'Secure Access',
    Finance: 'Track Expenses',
  };
  return subtitles[title as keyof typeof subtitles] || 'Productivity Tool';
};

const apps = ref([
  {
    title: 'Notes',
    description:
      'Organize your thoughts and ideas with our powerful note-taking application featuring rich text editing and collaboration.',
    icon: 'mdi-note-outline',
    color: 'blue',
    route: '/note_app/notes?page=all_notes',
    features: [
      'Rich text editor with formatting',
      'File attachments and images',
      'Tags and categories',
      'Collaborative editing',
      'Version history',
    ],
  },
  {
    title: 'Todo Lists',
    description:
      'Stay organized and boost productivity with task lists, due dates, and progress tracking for all your projects.',
    icon: 'mdi-checkbox-marked-outline',
    color: 'teal',
    route: '/todo_app/todos',
    features: [
      'Create multiple task lists',
      'Drag and drop reordering',
      'Task notes and details',
      'Completion tracking',
      'Search and filter tasks',
    ],
  },
  {
    title: 'Contacts',
    description:
      'Manage your professional and personal contacts efficiently with our comprehensive contact management system.',
    icon: 'mdi-account-group-outline',
    color: 'green',
    route: '/contact_app/contacts',
    features: [
      'Import/Export contacts',
      'Custom fields and groups',
      'Birthday reminders',
      'Contact history',
      'Quick search and filters',
    ],
  },
  {
    title: 'Blog',
    description:
      'Share your stories and insights with our user-friendly blogging platform featuring SEO optimization.',
    icon: 'mdi-post-outline',
    color: 'purple',
    route: '/blog_app/articles',
    features: [
      'Markdown support',
      'SEO optimization',
      'Comments and reactions',
      'Analytics dashboard',
      'Social media sharing',
    ],
  },
  {
    title: 'Password Manager',
    description:
      'Keep your passwords secure and easily accessible with industry-standard encryption and security features.',
    icon: 'mdi-shield-key-outline',
    color: 'red',
    route: '/safezone_app/passwords',
    features: [
      'End-to-end encryption',
      'Password generator',
      'Secure sharing',
      'Browser extension',
      'Two-factor authentication',
    ],
  },
  {
    title: 'Finance',
    description:
      'Track your expenses and manage your financial life with comprehensive budgeting and reporting tools.',
    icon: 'mdi-chart-line',
    color: 'amber',
    route: '/my_finance_app/expenses',
    features: [
      'Expense tracking',
      'Budget planning',
      'Financial reports',
      'Bill reminders',
      'Multiple currency support',
    ],
  },
]);

const features = ref([
  {
    title: 'Secure',
    description:
      'Your data is protected with industry-standard encryption and modern security practices.',
    icon: 'mdi-shield-check-outline',
    color: 'success',
  },
  {
    title: 'Fast',
    description:
      'Lightning-fast performance across all applications with optimized code and efficient architecture.',
    icon: 'mdi-speedometer',
    color: 'info',
  },
  {
    title: 'Integrated',
    description: 'All your productivity tools work seamlessly together in one unified platform.',
    icon: 'mdi-apps',
    color: 'primary',
  },
]);

const stats = ref([
  { value: '99.9%', label: 'Uptime' },
  { value: '24/7', label: 'Support' },
  { value: '256-bit', label: 'Encryption' },
  { value: '6+', label: 'Applications' },
]);
</script>

<style scoped>
.v-card {
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}

.v-card:hover {
  transform: translateY(-2px);
}
</style>
