import { h, onMounted, onUnmounted } from 'vue';
import { createMemoryHistory, createRouter } from 'vue-router';
import { flushPromises, mount } from '@vue/test-utils';
import Dashboard from '../Dashboard.vue';

vi.mock('dashboard/composables/useUISettings', async () => {
  const { ref } = await import('vue');
  return {
    useUISettings: () => ({ uiSettings: ref({}), updateUISettings: vi.fn() }),
  };
});

vi.mock('dashboard/composables/useAccount', async () => {
  const { ref } = await import('vue');
  return { useAccount: () => ({ accountId: ref(1) }) };
});

const RoutedContent = { template: '<div class="routed-content" />' };

describe('Dashboard', () => {
  let wrapper;

  const mountDashboard = async () => {
    const commandBar = { mounts: 0, opens: 0 };
    const router = createRouter({
      history: createMemoryHistory(),
      routes: [{ path: '/', name: 'home', component: RoutedContent }],
    });
    await router.push({ name: 'home' });
    await router.isReady();

    const CommandBar = {
      setup() {
        commandBar.mounts += 1;
        const onKeydown = event => {
          if (event.key === 'k' && (event.metaKey || event.ctrlKey)) {
            commandBar.opens += 1;
          }
        };
        onMounted(() => document.addEventListener('keydown', onKeydown));
        onUnmounted(() => document.removeEventListener('keydown', onKeydown));
        return () => h('div', { class: 'command-bar' });
      },
    };

    wrapper = mount(Dashboard, {
      global: {
        plugins: [router],
        stubs: {
          CommandBar,
          NextSidebar: true,
          MobileSidebarLauncher: true,
          CopilotLauncher: true,
          CopilotContainer: true,
          AddAccountModal: true,
          WootKeyShortcutModal: true,
        },
      },
    });
    await flushPromises();
    return commandBar;
  };

  afterEach(() => wrapper?.unmount());

  it('renders routed content without an upgrade wall', async () => {
    await mountDashboard();
    expect(wrapper.find('.routed-content').exists()).toBe(true);
  });

  it('keeps the command bar available', async () => {
    const commandBar = await mountDashboard();
    expect(wrapper.find('.command-bar').exists()).toBe(true);
    expect(commandBar.mounts).toBe(1);
  });
});
