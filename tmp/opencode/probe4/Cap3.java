public class Cap3 {
    public static void main(String[] args) throws Exception {
        Class<?> c = Class.forName("Default.Main");
        java.lang.reflect.Method m = c.getDeclaredMethod("main");
        m.invoke(null);
    }
}
