<script setup>
import { computed } from 'vue';

const props = defineProps({
  headers: {
    type: Array,
    default: () => [],
  },
  items: {
    type: Array,
    default: () => [],
  },
  noDataMessage: {
    type: String,
    default: '',
  },
  loading: {
    type: Boolean,
    default: false,
  },
});

const hasHeaderSlot = computed(() => !!props.headers.length);
const showHeaders = computed(
  () => hasHeaderSlot.value && props.items.length > 0
);
</script>

<template>
  <div class="w-full">
    <table class="min-w-full table-auto border-separate border-spacing-0">
      <thead v-if="showHeaders" class="border-b border-n-border bg-n-muted/50">
        <tr>
          <th
            v-for="(header, index) in headers"
            :key="index"
            class="h-12 px-4 text-start text-sm font-medium text-n-muted-foreground capitalize"
          >
            <slot :name="`header-${index}`" :header="header">
              {{ header }}
            </slot>
          </th>
        </tr>
      </thead>
      <tbody class="divide-y divide-n-border text-n-foreground">
        <template v-if="items.length">
          <slot name="row" :items="items" />
        </template>
        <tr v-else-if="noDataMessage && !loading">
          <td
            :colspan="headers.length || 1"
            class="py-20 text-center text-body-main !text-base text-n-slate-11"
          >
            {{ noDataMessage }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
