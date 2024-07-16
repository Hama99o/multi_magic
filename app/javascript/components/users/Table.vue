<template>
  <div>
    <v-table>
      <thead>
        <tr>
          <th class="text-left">
            Name
          </th>
          <th class="text-left">
            Access level
          </th>
          <th class="text-left">
            Email
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in users"
          :key="item.name"
        >
          <td class="px-0 ">
            <router-link
              :to="{ name: 'user', params: {id: item.id } }"
              class="w-full h-full"
            >

            <div v-if="item?.fullname" class="w-[45px] h-full flex gap-2 items-center pl-4 whitespace-nowrap">
              {{ item.fullname }}
            </div>
            </router-link>
          </td>

          <td class="px-0">
            <router-link
              :to="{ name: 'user', params: {id: item.id } }"
              class="w-full h-full"
            >
            <div v-if="item?.access_level" class="w-[45px] h-full flex gap-2 items-center pl-4 whitespace-nowrap">
              {{ item.access_level }}
            </div>
            </router-link>
          </td>

          <td class="px-0">
            <router-link
              :to="{ name: 'user', params: {id: item.id } }"
              class="w-full h-full"
            >
            <div v-if="item?.email" class="w-[45px] h-full flex gap-2 items-center pl-4 whitespace-nowrap">
              {{ item.email }}
            </div>
            </router-link>
          </td>

        </tr>
      </tbody>
    </v-table>
</div>
</template>

<script setup>

const props = defineProps({
  users: { type: Array, default: () => [] },
});

</script>
