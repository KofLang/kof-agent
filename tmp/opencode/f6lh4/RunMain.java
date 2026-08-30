public class RunMain {
    public static void main(String[] a) throws Exception {
        Class<?> c = Class.forName("Default.Main");
        for (java.lang.reflect.Method m : c.getDeclaredMethods()) {
            System.out.println(m.getName() + " " + m);
        }
        java.lang.reflect.Method m = c.getDeclaredMethod("kof_test_0");
        m.invoke(null);
        System.out.println("kof_test_0 OK");
        m = c.getDeclaredMethod("kof_test_1");
        m.invoke(null);
        System.out.println("kof_test_1 OK");
        m = c.getDeclaredMethod("kof_test_2");
        m.invoke(null);
        System.out.println("kof_test_2 OK");
    }
}
