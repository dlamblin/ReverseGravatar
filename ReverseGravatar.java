import java.lang.RuntimeException;
import java.lang.String;
import java.lang.StringBuilder;
import java.lang.System;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.function.Function;

import javax.xml.bind.DatatypeConverter;

class ReverseGravatar {

  public static final HashSet<String> hashes = new HashSet<>();
  public static final HashSet<String> names = new HashSet<>();
  public static final String[] seperators = {"_", ".", ":", ";", ""};
  public static final String[] domains
      = {"gmail", "hotmail", "yahoo", "mailinator", "aol", "verizon", "speakeasy"};
  public static final String[] tlds = {"com", "net", "org", "edu", "co.uk", "fr"};

  public static void main(String... args) throws NoSuchAlgorithmException, IOException {
    names.add("");
    ArrayList<String> emails = handleArgs(args);
    generateEmails(emails);
    hashAndCheck(emails, getMd5AndEmailViaDatatypeConverter());
  }

  public static ArrayList<String> handleArgs(String[] args) throws IOException {
    for (String arg : args) {
      Path p = Paths.get(arg);
      if (Files.exists(p)) {
        processFile(p);
      } else {
        storeNameOrHash(arg.toLowerCase());
      }
    }
    int n = names.size();
    int combinations = n * n * n * seperators.length * domains.length * tlds.length;
    return new ArrayList<>(combinations);
  }

  public static void processFile(Path p) throws IOException {
    Files.lines(p).flatMap(s -> Arrays.stream(s.toLowerCase().split("\\s+")))
        .forEach(s -> storeNameOrHash(s));
  }

  public static void storeNameOrHash(String s) {
    if (s.matches("[a-f0-9]{32}")) {
      hashes.add(s);
    } else {
      names.add(s);
      names.add(s.substring(0, 1));
    }
  }

  public static void generateEmails(ArrayList<String> emails) {
    HashSet<String> namesOrEmpty = names;
    HashSet<String> empty = new HashSet<>();
    empty.add("");
    for (String fn: names) {
      if (fn.isEmpty()) {
        continue;
      }
      for (String mn: names) {
        namesOrEmpty = mn.isEmpty() ? empty : names;
        for (String ln: namesOrEmpty) {
          for (String s : seperators) {
            for (String d : domains) {
              for (String t : tlds) {
                StringBuilder email = new StringBuilder(fn);
                if (!mn.isEmpty()) {
                  email.append(s).append(mn);
                }
                if (!ln.isEmpty()) {
                  email.append(s).append(ln);
                }
                email.append('@').append(d).append('.').append(t);
                emails.add(email.toString());
              }
            }
          }
        }
      }
    }
  }

  public static void hashAndCheck(ArrayList<String> emails, Function<String, String> md5AndEmail) {
    emails.parallelStream()
        .map(md5AndEmail)
        .forEach(s -> {
          String[] tupple = s.split("≈", 2);
          String hash = tupple[0], email = tupple[1];
          if (hashes.contains(hash)) {
            System.out.printf("Hash: %s <= Email: %s MATCHES!\n", hash, email);
          } else {
            System.err.printf("Hash: %s <= Email: %s\n", hash, email);
          }
        });
  }

  public static Function<String, String> getMd5AndEmailViaDatatypeConverter() {
    return s -> {
      try {
        return DatatypeConverter.printHexBinary(
            MessageDigest.getInstance("MD5").digest(s.getBytes(StandardCharsets.UTF_8)))
                   .toLowerCase()
               + "≈" + s;
      } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException(e);
      }
    };
  }

  public static Function<String, String> getMd5AndEmailViaBigInteger() {
    return s -> {
      try {
        return String.format(
            "%032x≈%s",
            new BigInteger(1,
                           MessageDigest.getInstance("MD5").digest(s.getBytes(StandardCharsets.UTF_8))),
            s);
      } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException(e);
      }
    };
  }
}