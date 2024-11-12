<template>
  <v-toolbar class="bg-surface" app>
    <!-- for mobile -->
    <span v-if="isMobile && AuthService.getUser()?.id">
      <v-app-bar-nav-icon class="text-primary" @click="sidebar = !sidebar"></v-app-bar-nav-icon>
    </span>

    <!-- Menu that appears when the button is clicked -->
    <dropdown
      v-if="
        (currentUser && isImpersonating) ||
        (currentUser && !isImpersonating && AuthService?.isSuperAdmin())
      "
      :offset="8"
    >
      <template #activator="{ props }">
        <v-btn icon v-bind="props">
          <v-icon class="text-primary">mdi-cog-outline</v-icon>
        </v-btn>
      </template>

      <template #dropdown>
        <!-- Optional overlay for theme change transition -->
        <div
          v-if="isChangingTheme"
          class="theme-transition-overlay absolute inset-0 bg-accent"
        ></div>

        <v-list>
          <v-list-item
            v-if="AuthService?.isSuperAdmin() || isImpersonating"
            :lines="false"
            density="compact"
            class="hover:bg-info"
            @click="openImpersonatingUser()"
          >
            <v-list-item-title class="m-0 p-0 text-sm"> Impersonate User </v-list-item-title>
          </v-list-item>

          <v-list-item
            v-if="isImpersonating"
            :lines="false"
            density="compact"
            class="hover:bg-info"
            @click="stopImpersonatingUser()"
          >
            <v-list-item-title class="m-0 p-0 text-sm"> Remove Impersonating </v-list-item-title>
          </v-list-item>
        </v-list>
      </template>
    </dropdown>

    <v-toolbar-title v-if="AuthService.getUser()?.id">
      <div class="flex gap-12">
        <router-link
          v-if="!isMobile"
          to="/"
          tag="span"
          style="cursor: pointer"
          class="d-flex align-center w-fit no-underline"
        >
          <img alt="Multi Magics" style="width: 30px" src="@/assets/logos/image.png" class="mr-3" />
          <span>
            {{ appTitle }}
          </span>
        </router-link>

        <!-- Dropdown menu for selecting themes -->
        <v-menu v-model="isMenuOpen">
          <template #activator="{ props }">
            <v-btn icon size="x-small" @click="isMenuOpen = !isMenuOpen" v-bind="props">
              <v-icon class="text-primary">{{ selectThemeIcon }}</v-icon>
            </v-btn>
          </template>

          <!-- Animated dropdown menu with theme options -->
          <v-list dense>
            <!-- Theme selection radio group inside the dropdown -->
            <v-radio-group v-model="selectedTheme" hide-details @change="changeTheme(null)">
              <v-list dense>
                <!-- Iterate over the theme options and render radio buttons -->
                <v-list-item
                  v-for="themeOption in themes"
                  :key="themeOption.value"
                  @click="
                    selectedTheme = themeOption.value;
                    changeTheme(themeOption.value);
                  "
                >
                  <v-radio :value="themeOption.value" class="flex items-center gap-3">
                    <!-- Custom label slot with icon and text -->
                    <template #label>
                      <v-icon class="text-primary" :icon="themeOption.icon" />
                      {{ themeOption.name }}
                    </template>
                  </v-radio>
                </v-list-item>
              </v-list>
            </v-radio-group>
          </v-list>
        </v-menu>
      </div>
    </v-toolbar-title>
    <v-spacer></v-spacer>

    <!-- for desktop -->
    <v-toolbar-items>
      <v-btn
        v-for="item in filteredMenuItems"
        v-if="!isMobile"
        :key="item.title"
        class="d-flex align-center"
        flat
        :to="{
          name: item.routeName,
          query: data?.query,
        }"
      >
        <v-icon class="text-primary" :icon="item.icon" />
        {{ item.title }}
      </v-btn>
    </v-toolbar-items>

    <!-- Conversations Button -->
    <v-toolbar-items v-if="isUserLogIn">
      <!-- Message List Dropdown -->
      <v-menu v-model="dropdownOpen" :close-on-content-click="false" max-height="496">
        <template #activator="{ props }">
          <!-- Message icon that opens dropdown -->
          <v-btn icon v-bind="props">
            <v-icon :color="unreadMessagesCount ? 'yellow' : 'primary'">mdi-chat-outline</v-icon>
          </v-btn>
        </template>

        <div class="min-w-[302px] bg-secondary">
          <!-- <v-list min-width="300" max-width="250"  class="bg-grey"> -->
          <div class="mx-3 flex items-center justify-between pb-2">
            <h3>Chats</h3>

            <v-btn class="mt-1 bg-surface" icon size="small" @click="openShowNewConversationModal">
              <v-icon class="text-primary">mdi-pencil</v-icon>
            </v-btn>
          </div>

          <!-- Conversations list -->
          <ConversationList
            :conversations="conversations"
            list-height="320"
            :conversation-id="conversationId"
            :current-user-id="currentUser?.id"
            @select-conversation="openConversation"
            @load-more-data="loadMoreData"
            @search-conversation="searchConversation"
          />
          <!-- </v-list> -->
        </div>
        <!-- See all conversations link -->
        <v-list-item class="bg-secondary" @click="goToAllConversations">
          <div>
            <v-list-item-title class="text-accent underline"
              >See all conversations</v-list-item-title
            >
          </div>
        </v-list-item>
      </v-menu>
    </v-toolbar-items>

    <app-grid-menu
      v-if="isUserLogIn && !isMobile"
      :is-super-admin="AuthService?.isSuperAdmin()"
      :current-user="currentUser"
    />

    <!-- for logout -->
    <v-toolbar-items v-if="!isUserLogIn">
      <v-btn
        v-for="item in menuLogOutItems"
        :key="item.title"
        class="d-flex align-center"
        flat
        :to="{
          name: item.routeName,
        }"
      >
        <v-icon class="mr-1 text-primary" :icon="item.icon" />
        {{ item.title }}
      </v-btn>
    </v-toolbar-items>

    <div>
      <dropdown>
        <template #activator>
          <user-avatar
            class="mr-5 cursor-pointer"
            size="lg"
            :avatar="currentUser?.avatar"
            :firstname="currentUser?.lastname"
            :lastname="currentUser?.firstname"
          />
        </template>

        <template #dropdown>
          <div class="flex w-full flex-col gap-2 border py-2">
            <div class="flex flex-col gap-2">
              <!-- User email -->
              <p class="text-center text-xs">
                {{ currentUser?.email }}
              </p>

              <div class="flex flex-col items-center gap-3">
                <user-avatar
                  class="mr-5 cursor-pointer"
                  size="2xl"
                  :avatar="currentUser?.avatar"
                  :firstname="currentUser?.lastname"
                  :lastname="currentUser?.firstname"
                />
                <!-- User Firstname & Lastname -->
                <p class="px-4">
                  hello,
                  <span class="text-xl uppercase">
                    {{ currentUser?.firstname }} {{ currentUser?.lastname }}
                  </span>
                </p>
              </div>
            </div>

            <v-divider color="black" class="mx-4 opacity-100" />

            <!-- Buttons -->
            <div class="flex flex-col">
              <!-- Profile-->
              <div
                class="flex h-[35px] cursor-pointer items-center justify-center gap-2 px-4 hover:bg-info"
                @click="goToProfile"
              >
                <div>
                  <Icon icon="mdi:person-outline" width="16" height="16" class="text-fakeBlack" />
                </div>

                <p class="!w-full text-xs">
                  {{ 'Profile' }}
                </p>
              </div>

              <!-- Log out -->
              <div
                class="flex h-[35px] cursor-pointer items-center justify-center gap-2 px-4 hover:bg-info"
                @click="signOut"
              >
                <div>
                  <Icon icon="mdi:logout" width="16" height="16" class="text-fakeBlack" />
                </div>

                <p class="!w-full text-xs">
                  {{ 'Logout' }}
                </p>
              </div>
            </div>
          </div>
        </template>
      </dropdown>
    </div>
  </v-toolbar>

  <v-navigation-drawer v-if="isMobile" v-model="sidebar" app>
    <div class="flex h-14 w-full items-center justify-between py-2 pl-4 pr-2">
      <span
        class="flex cursor-pointer items-center justify-center"
        @click="router.push({ name: 'index' })"
      >
        <img alt="" style="width: 22px" src="@/assets/logos/image.png" class="mr-3" />
        {{ appTitle }}
      </span>

      <Icon
        class="cursor-pointer text-primary hover:bg-sky-700"
        icon="mingcute:close-line"
        @click="sidebar = !sidebar"
      />
    </div>
    <v-list>
      <v-list-item to="/" prepend-icon="mdi-home" title="Home"></v-list-item>

      <v-list-group v-for="app in filterMenuApplicationPages" :value="app.appName">
        <template #activator="{ props }">
          <v-list-item
            v-bind="props"
            :prepend-icon="app.icon"
            :title="app.appNameWithSpace"
          ></v-list-item>
        </template>

        <v-list-item
          v-for="(data, i) in app.pages"
          :key="i"
          :prepend-icon="data.icon"
          :title="data.title"
          :value="data.title"
          :to="{
            name: data.routeName,
            query: data?.query,
          }"
        ></v-list-item>
      </v-list-group>
    </v-list>
  </v-navigation-drawer>

  <div class="flex items-center space-x-2">
    <!-- Autocomplete Dropdown -->
    <v-autocomplete
      v-if="showAutocomplete"
      :items="users"
      item-value="id"
      item-title="fullname"
      label="Search User"
      hide-details
      dense
      class="w-[200px]"
      @update:search="searchUser"
    >
      <template #item="{ item }">
        <v-list-item
          class="cursor-pointer rounded-md transition-colors duration-200 hover:bg-gray-100"
          @click="startImpersonatingUser(item.raw.id)"
        >
          <v-row class="flex flex-col gap-1">
            <v-col class="flex flex-col">
              <span class="text-sm font-medium">{{ item.raw.fullname }}</span>
            </v-col>
          </v-row>
        </v-list-item>
      </template>
    </v-autocomplete>
  </div>

  <!-- Render multiple chat windows dynamically -->
  <ChatWindow
    v-for="chat in openChats"
    :key="chat.id"
    :user="chat.sender_name"
    :conversation="chat"
    @close="closeChat(chat.id)"
  />

  <!-- New Conversation Modal -->
  <NewConversation
    ref="showNewConversationModal"
    :search-results="searchResults"
    @create-new-conversation="createNewConversation"
    @search-users="searchUsers"
  />
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { debounce } from 'lodash';
import { storeToRefs } from 'pinia';
import { useRoute, useRouter } from 'vue-router';
import { Icon } from '@iconify/vue';
import { useAuthStore } from '@/stores/auth.store';
import { useConversationStore } from '@/stores/conversation.store';
import AuthService from '@/services/auth.service';
import { useUserStore } from '@/stores/user.store';
import UserAvatar from '@/components/tools/Avatar.vue';
import Dropdown from '@/components/button/Dropdown.vue';
import ChatWindow from '@/components/conversation/ChatWindow.vue';
import AppGridMenu from '@/components/layouts/AppGridMenu.vue';
import { useMobileStore } from '@/stores/mobile';
import NewConversation from '@/components/conversation/New.vue';
import ConversationList from '@/components/conversation/ConversationList.vue';

const {
  fetchConversations,
  createConversation,
  fetchUnreadMessagesCount,
  fetchConversationsWithInfiniteScroll,
} = useConversationStore();

const {
  conversations,
  page: conversationPage,
  search: conversationSearch,
  pagination: conversationPagination,
  unreadMessagesCount,
} = storeToRefs(useConversationStore());

const {
  fetchCurrentUser,
  fetchUser,
  fetchUsers,
  updateUser,
  impersonateUser,
  stopImpersonating,
  fetcGlobalhUsers,
} = useUserStore();
const { currentUser, theme, users, isImpersonating, search, openChats } = storeToRefs(useUserStore());
const { isMobile } = storeToRefs(useMobileStore());
const showNewConversationModal = ref(false); // Control for modal visibility
const searchResults = ref([]); // Store search results
const selectedConversationId = ref(null);
const selectedConversation = ref(null);

onMounted(async () => {
  try {
    if (AuthService.getUser()?.id) {
      await fetchCurrentUser(AuthService.getUser()?.id);
      await fetchConversations();
      await fetchUnreadMessagesCount();
      localStorage.setItem('user', JSON.stringify(currentUser?.value));
      menuApplicationPages.value = menuApplicationPages.value.map((item) => {
        if (currentUser.value?.applications?.includes(item.appName)) {
          item.isAllowed = true;
          return item;
        } else {
          return item;
        }
      });
    }
  } catch (error) {
    console.log(error);
  }
});
const router = useRouter();

// Using Vue Router's useRoute to get the current route
const route = useRoute();

// Function to determine the selected application based on the current route
const selectedAppName = ref(null);
const appTitle = ref('Multi Magic');
const sidebar = ref(false);
const settingsMenu = ref(false);
const authStore = useAuthStore();
const showAutocomplete = ref(false);
const searchQuery = ref('');
const dropdownOpen = ref(false);
// const hasUnreadMessages = ref(messages.value.some(message => !message.is_read))
const hasUnreadMessages = ref([]);
// Array to keep track of open conversations

const filteredMenuItems = computed(() => {
  const appMenu = menuApplicationPages.value.find(
    (menu) => menu.isAllowed && menu.appName === selectedAppName.value,
  );
  return appMenu ? appMenu.pages : [];
});

const menuApplicationPages = ref([
  {
    appName: 'NoteApp',
    appNameWithSpace: 'My Notes',
    baseRoute: '/note_app/',
    isAllowed: false,
    icon: 'mdi mdi-note',
    pages: [
      {
        title: 'Notes',
        routeName: 'notes',
        icon: 'mdi mdi-note-edit',
        query: { page: 'all_notes' },
      },
      // More Notes pages
    ],
  },
  {
    appName: 'MyFinanceApp',
    appNameWithSpace: 'My Finance',
    baseRoute: '/my_finance_app/',
    isAllowed: false,
    icon: 'mdi mdi-cash-multiple',
    pages: [
      {
        title: 'Expenses',
        routeName: 'expenses',
        icon: 'mdi mdi-currency-usd',
        query: {},
      },
      {
        title: 'Loans',
        routeName: 'loans',
        icon: 'mdi mdi-cash',
        query: {},
      },
      // More MyFinanceApp pages
    ],
  },
  {
    appName: 'ContactApp',
    isAllowed: false,
    appNameWithSpace: 'My Contacts',
    baseRoute: '/contact_app/',
    icon: 'mdi mdi-account-box',
    pages: [
      {
        title: 'Contacts',
        routeName: 'contacts',
        icon: 'mdi mdi-account-box-outline',
        query: {},
      },
      // More Users pages
    ],
  },
  {
    appName: 'Users',
    isAllowed: false,
    appNameWithSpace: 'All  Users',
    baseRoute: '/users',
    icon: 'mdi-account-group',
    pages: [
      {
        title: 'Users',
        routeName: 'users',
        icon: 'mdi mdi-account-supervisor-circle',
        query: {},
      },
      // More Users pages
    ],
  },
  {
    appName: 'BlogApp',
    isAllowed: false,
    appNameWithSpace: 'My Blog',
    baseRoute: '/blog_app/',
    icon: 'mdi mdi-school',
    pages: [
      {
        title: 'blog',
        routeName: 'articles',
        icon: 'mdi mdi-book-open-page-variant',
        query: {},
      },
      {
        title: 'Create Post',
        routeName: 'new_article',
        icon: 'mdi mdi-notebook-edit',
        query: {},
      },
      // More Users pages
    ],
  },
]);

const menuLogOutItems = ref([
  {
    title: 'My Blog',
    routeName: 'articles',
    icon: 'mdi mdi-school',
    appName: 'BlogApp',
    query: {},
  },
  { title: 'Index', routeName: 'index', icon: 'mdi-home-circle', allow: true },
  // { title: 'About', routeName: 'about', icon: "mdi-face-man-shimmer-outline", allow: true },
  { title: 'Sign in', routeName: 'login', icon: ' mdi-login', allow: true },
  { title: 'Sign up', routeName: 'signup', icon: 'mdi-account-plus-outline', allow: true },
]);

const searchConversation = debounce(async (search) => {
  conversationSearch.value = search;
  conversationPage.value = 1;
  await fetchConversations(conversationPage.value, conversationSearch.value);
}, 200);

// Function to open a conversation window
const openConversation = async (conversation) => {
  dropdownOpen.value = false;

  // Find the index of the existing conversation in openChats
  const existingChatIndex = openChats.value.findIndex((chat) => chat.id === conversation.id);

  if (existingChatIndex === -1) {
    // If it doesn't exist, add it to the beginning of openChats
    openChats.value.push({ ...conversation });
  } else {
    // If it exists, move it to the first position
    const [existingChat] = openChats.value.splice(existingChatIndex, 1);
    openChats.value.push(existingChat);
  }
};


// Function to close a specific chat window
const closeChat = (id) => {
  openChats.value = openChats.value.filter((chat) => chat.id !== id);
};

const filterMenuApplicationPages = computed(() => {
  return menuApplicationPages.value.filter((item) =>
    currentUser.value?.applications?.includes(item.appName),
  );
});

// Methods to toggle dropdown and navigate
const toggleMessageDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value;
};

const goToAllConversations = () => {
  // Navigate to the conversation page
  dropdownOpen.value = false;
  router.push({ name: 'conversations' }); // Use Vue Router
};

const determineSelectedApp = () => {
  const currentPath = route.path;
  const matchedApp = menuApplicationPages.value.find((app) =>
    currentPath.startsWith(app.baseRoute),
  );
  selectedAppName.value = matchedApp ? matchedApp.appName : null;
};

// Watch the route to update the selected application when the route changes
watch(route, () => {
  determineSelectedApp();
});

// Initial determination of the selected application
determineSelectedApp();

const logout = () => {
  authStore.logout();
};

const isUserLogIn = computed(() => {
  return AuthService?.getUser() && AuthService?.getToken();
});

const selectThemeIcon = computed(() => {
  return themes.value.find((t) => t.value == theme.value)?.icon;
});

const goToProfile = async () => {
  await fetchUser(currentUser.value?.id);
  router.push({
    name: 'user',
    params: { id: currentUser.value?.id },
  });
};

const signOut = async () => {
  try {
    logout();
    localStorage.removeItem('user');
    localStorage.removeItem('token');
    location.href = '/';
  } catch (error) {
    console.log(error);
  }
};

const toggleTheme = () => {
  theme.value = theme.value === 'light' ? 'dark' : 'light';
  updateUser(currentUser.value?.id, { theme: theme.value });
  settingsMenu.value = false;
};

const searchUser = debounce(async (value) => {
  try {
    search.value = value;
    const res = await fetchUsers();
  } catch (error) {
    console.log(error);
  }
}, 350);

const startImpersonatingUser = async (userId) => {
  try {
    await impersonateUser(userId);
    redirectToHome();
  } catch (error) {
    console.log(error);
  }
};

const stopImpersonatingUser = async () => {
  try {
    await stopImpersonating();
    redirectToHome();
  } catch (error) {
    console.log(error);
  }
};

const redirectToHome = () => {
  router.push({ name: 'index' }).then(() => {
    router.go(0);
  });
};

const openImpersonatingUser = () => {
  showAutocomplete.value = !showAutocomplete.value;
  searchUser();
};

const filteredUsers = computed(() => {
  if (!searchQuery.value) {
    return users.value;
  }
  return users.value.filter((user) =>
    user.name.toLowerCase().includes(searchQuery.value.toLowerCase()),
  );
});

const themes = ref([
  { name: 'Light', value: 'light', icon: 'mdi-white-balance-sunny', color: 'text-[#1976D2]' },
  { name: 'Dark', value: 'dark', icon: 'mdi-moon-waning-crescent', color: 'text-[#BB86FC]' },
  { name: 'Blackguard', value: 'blackguard', icon: 'mdi-shield-outline', color: 'text-[#FF4081]' },
  { name: 'Polaris', value: 'polaris', icon: 'mdi-star-outline', color: 'text-[#0d3c61]' },
  {
    name: 'Nebula',
    value: 'nebula',
    icon: 'mdi mdi-rocket-launch-outline',
    color: 'text-[#7B1FA2]',
  },
  { name: 'System', value: 'system', icon: 'mdi mdi-laptop', color: 'text-[#7a7a7a]' },
]);

const selectedTheme = ref(theme.value);
const isMenuOpen = ref(false);
const isChangingTheme = ref(false);

const changeTheme = (newTheme: string) => {
  isChangingTheme.value = true;
  if (newTheme) {
    selectedTheme.value = newTheme;
  }
  updateUser(currentUser.value?.id, { theme: selectedTheme.value });
  settingsMenu.value = false;

  // Wait for the next frame to ensure the overlay is visible before starting the transition
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      theme.value = newTheme;
      setTimeout(() => {
        isChangingTheme.value = false;
      }, 300); // Match this with the CSS transition duration
    });
  });
};

// Watch for theme changes from outside this component
watch(
  () => theme.value,
  (newTheme) => {
    selectedTheme.value = newTheme;
  },
);

// Create a new conversation when a user is selected
const createNewConversation = async (user) => {
  const res = await createConversation(user.id);
  selectedConversation.value = res.conversation;
  conversations.value.unshift(res.conversation);
  showNewConversationModal.value.dialog = false; // Close the modal
  openConversation(selectedConversation.value); // Automatically select the new conversation
};

// Search for users using search query
const searchUsers = async (searchQuery) => {
  if (searchQuery.length > 1) {
    // Start searching after 3 characters
    const results = await fetcGlobalhUsers(1, searchQuery);
    searchResults.value = results;
  } else {
    searchResults.value = [];
  }
};

// open a new conversation dialog
const openShowNewConversationModal = async () => {
  showNewConversationModal.value.dialog = true; // Close the modal
  const results = await fetcGlobalhUsers();
  searchResults.value = results;
};

const conversationClasses = computed(() => {
  const conversationClasses = {};
  conversations.value.forEach((conversation) => {
    if (
      conversations.value != conversation?.id &&
      conversation?.last_message &&
      !conversation?.last_message?.read_at &&
      !conversation?.last_message?.sent_by_me
    ) {
      conversationClasses[conversation.id] = '!bg-warning';
    }
  });
  return conversationClasses;
});

async function loadMoreData({ done }) {
  if (conversationPage.value < conversationPagination.value.total_pages) {
    try {
      conversationPage.value++;
      const conversationData = await fetchConversationsWithInfiniteScroll();
      if (conversationData.length) {
        conversations.value.push(...conversationData);
      }
      done('ok');
    } catch (error) {
      done('error');
    }
  } else {
    done('empty');
  }
}
</script>

<style>
@import 'vuetify/styles';
@import '@/assets/css/style.css';
</style>
