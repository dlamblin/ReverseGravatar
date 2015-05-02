import java.io.Console;
import java.util.Map.Entry;
import java.util.Scanner;

public class SystemProperties {
    public static boolean propsLong = false;
    public static void main(String... args) throws Exception {
        if (0 == args.length) {
            listPropsShort();
        }
        for (String name : args) {
            if (name.equals("-l")) {
                listPropsLong();
                continue;
            }
            String value = "«UNDEFINED–PROPERTY»";
            try {
                value = System.getProperty(name, value);
            } catch (NullPointerException npe) {
                value = "«NULL–VALUE»";
            } catch (IllegalArgumentException iae) {
                value = "«KEY–EMPTY: " + iae.toString() + "»";
            } catch (SecurityException se) {
                value = "«SECUIRTY–EXCEPTION: " + se.toString() + "»";
            } catch (Exception e) {
                value = "«EXCEPTION: " + e.toString() + "»";
            } finally {
                System.out.printf("%s=%s", name, value).println();
            }
        }
        System.out.flush();
        Console c;
        if ((c = System.console()) != null) {
            String[] e = {"/bin/stty","raw"};
            Runtime r = Runtime.getRuntime();
            r.exec(e);
            int in = 0;
            while (in != -1) {
                in = c.reader().read();
                if (in == -1) {
                    c.format("Closed\n").flush();
                    continue;
                }
                if (in == ' ') {
                    c.format("Toggle\n").flush();
                }
                if (in == '\033') {
                    in = c.reader().read();
                    if (in == '[') {
                        in = c.reader().read();
                        if (in == 'A') {
                            c.format("Up Arrow\n").flush();
                        }
                        if (in == 'B') {
                            c.format("Down Arrow\n").flush();
                        }
                        if (in == 'C') {
                            c.format("Right Arrow\n").flush();
                        }
                        if (in == 'D') {
                            c.format("Left Arrow\n").flush();
                        }
                    }
                }
            }
        }
        System.out.close();
    }
    public static void listPropsShort() {
            System.getProperties().list(System.out);
    }
    public static void listPropsLong() {
        if (propsLong) return;
        for(Entry p : System.getProperties().entrySet()) {
            System.out.printf("%s=%s", p.getKey(), p.getValue())
                .println();
        }
        propsLong = true;
    }
}
