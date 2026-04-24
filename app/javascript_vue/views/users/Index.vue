
<template>
  <div>
    <p class="my-5 text-4xl leading-10 text-center">
      Users
    </p>

    <v-text-field
      v-model="search"
      color="primary"
      class="w-full text-darkGrey md:w-[258px]"
      variant="outlined"
      density="compact"
      hide-details
      prepend-inner-icon="mdi-magnify"
      :label="'Search'"
      @update:model-value="searchUser"
      />
  </div>

  <user-table :users="users" />
  <v-pagination
    v-if="pagination"
    :model-value="pagination.current_page"
    :length="pagination.total_pages"
    :total-visible="6"
    theme="primary"
    variant="text"
    class="mt-16 !list-none"
    @update:model-value="fetchNewPage"
  />
</template>

<script setup>
import UserTable from '@/components/users/Table.vue';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user.store';
import { onMounted } from 'vue';

const { fetchUsers, resetStates } = useUserStore();

const { users, pagination, page, search } = storeToRefs(useUserStore());

onMounted(async () => {
try {
  await resetStates()
  await fetchUsers();
} catch (error) {
  console.log(error);
}
});

const fetchNewPage = async(e) => {
  page.value = e
  await fetchUsers();
};

const searchUser = async(e) => {
  search.value = e
  await fetchUsers();
};
</script>
