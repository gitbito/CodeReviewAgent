import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Larger demo that looks like a small production service.
 * Multiple components, simple APIs, background work.
 * It intentionally contains an unintended object retention point you can use for a demo.
 */
public class LargeLeakyService {

    // shared application-level event bus, lives for the lifetime of the app
    public static final EventBus EVENT_BUS = new EventBus();

    // application-level cache, intended for short lived items, but misused here
    public static final CacheManager CACHE = new CacheManager();

    public static void main(String[] args) throws Exception {
        LargeLeakyService app = new LargeLeakyService();
        app.start();
    }

    private final RequestHandler requestHandler = new RequestHandler();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    public void start() {
        // simulate background metric collection
        scheduler.scheduleAtFixedRate(() -> MetricsCollector.collect(), 0, 5, TimeUnit.SECONDS);

        // simulate incoming traffic, register a per-request listener unintentionally
        for (int i = 0; i < Integer.MAX_VALUE; i++) {
            RequestContext ctx = new RequestContext(i, new byte[128 * 1024]); // 128 KB
            requestHandler.handle(ctx);

            if (i % 100 == 0) {
                System.out.println("processed " + i + ", cache size " + CACHE.size());
            }

            try {
                TimeUnit.MILLISECONDS.sleep(50);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }

    /**
     * Simulates the HTTP or message handler.
     * It processes requests, updates cache, and registers a listener on the global event bus.
     * The listener is the source of unintended object retention in this demo.
     */
    public static class RequestHandler {

        public void handle(RequestContext ctx) {
            // process and cache some derived value
            String key = "ctx:" + ctx.id;
            CACHE.put(key, new CachedValue(ctx.id, System.currentTimeMillis()));

            // register a per-request listener on the global event bus
            // BUG: this anonymous listener captures ctx implicitly, and it is never unregistered
            EventListener listener = new EventListener() {
                @Override
                public void onEvent(String type, Object payload) {
                    // use ctx so the listener holds a strong reference to the whole RequestContext
                    if ("cleanup".equals(type)) {
                        if (ctx.id % 2 == 0) {
                            // pretend to do some cleanup
                            ctx.flag = true;
                        }
                    }
                }
            };

            // LEAK POINT: registering listener on a long lived EventBus without unregister
            EVENT_BUS.register(listener);

            // pretend other work
            MetricsCollector.recordProcessed();
        }
    }

    /**
     * Simple global event bus that holds strong references to listeners in a list.
     * Intended to be long lived. Listeners must be removed explicitly.
     */
    public static class EventBus {
        private final List<EventListener> listeners = Collections.synchronizedList(new ArrayList<>());

        public void register(EventListener listener) {
            listeners.add(listener);
        }

        public void unregister(EventListener listener) {
            listeners.remove(listener);
        }

        public void publish(String type, Object payload) {
            // copy to avoid ConcurrentModificationException
            List<EventListener> snapshot;
            synchronized (listeners) {
                snapshot = new ArrayList<>(listeners);
            }
            for (EventListener l : snapshot) {
                try {
                    l.onEvent(type, payload);
                } catch (Exception ignored) {
                }
            }
        }

        public int listenerCount() {
            return listeners.size();
        }
    }

    public interface EventListener {
        void onEvent(String type, Object payload);
    }

    /**
     * Cache manager that is intended to hold a small number of short lived entries.
     * In this demo it becomes large because callers add entries without eviction.
     */
    public static class CacheManager {
        private final Map<String, CachedValue> map = new ConcurrentHashMap<>();

        public void put(String key, CachedValue value) {
            map.put(key, value);
        }

        public CachedValue get(String key) {
            return map.get(key);
        }

        public int size() {
            return map.size();
        }

        public void clear() {
            map.clear();
        }
    }

    public static class CachedValue {
        public final int id;
        public final long ts;

        public CachedValue(int id, long ts) {
            this.id = id;
            this.ts = ts;
        }
    }

    /**
     * Simple metrics collector that runs in background.
     */
    public static class MetricsCollector {
        private static volatile long processed = 0;

        public static void recordProcessed() {
            processed++;
        }

        public static void collect() {
            // publish a periodic cleanup event
            EVENT_BUS.publish("cleanup", null);
            System.out.println("metrics processed " + processed + ", listeners " + EVENT_BUS.listenerCount());
        }
    }

    /**
     * Request context carries a payload and some state.
     * It is deliberately heavy to make retention obvious in heap dumps.
     */
    public static class RequestContext {
        public final int id;
        public final byte[] payload;
        public boolean flag;

        public RequestContext(int id, byte[] payload) {
            this.id = id;
            this.payload = payload;
        }
    }

    /**
     * Example demonstrating a NullPointerException (NPE).
     * This method intentionally dereferences a null reference so reviewers
     * can see the exact pattern that leads to an NPE. Do NOT call this
     * from production code — it's only for illustration / demo purposes.
     */
    public static void demonstrateNullPointer() {
        String maybeNull = null;
        // NPE POINT: the following line dereferences `maybeNull` which is null
        // and will throw a java.lang.NullPointerException at runtime.
        int len = maybeNull.length();
        // unreachable if NPE occurs, but left here for clarity
        System.out.println("length: " + len);
    }
}
