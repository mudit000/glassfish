import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by rohit on 7/12/17.
 */
public class DependencyReportGenerator {

    public static void main(String [] args) {
        try {
            String dependencyListFourFile = args[0];
            String dependencyListFiveFile = args[1];
            String dependencyChangesFile = args[2];

            /*
            String dependencyListFourFile = "/home/rohit/glassfish/source-build-5.0/dependencylist412.txt";
            String dependencyListFiveFile = "/home/rohit/glassfish/source-build-5.0/DependencyListGF5-74ab7bcca1236969e9994dac163e14c346d9c24e.txt";
            String dependencyChangesFile = "/home/rohit/glassfish/source-build-5.0/dependencyChanges.txt";
            String modifiedDependenciesFile = "/home/rohit/glassfish/source-build-5.0/modifiedDependencyNames.txt";
            */

            Map<String, String> dependencyFiveMap = new HashMap<>();
            Map<String, String> dependencyFourMap = new HashMap<>();

            String readLine;

            File f;
            BufferedReader b = null;

            ArrayList<String> modifiedDependencies = new ArrayList();

            f = new File(dependencyChangesFile);
            b = new BufferedReader(new FileReader(f));
            while ((readLine = b.readLine()) != null) {
                String splitWords[] = readLine.split(" ");
                if (!splitWords[0].contains("org.glassfish.main")) {
                    modifiedDependencies.add(splitWords[0]);
                }
            }

            f = new File(dependencyListFourFile);
            b = new BufferedReader(new FileReader(f));
            ArrayList<String> fourDependencyList = new ArrayList();

            while ((readLine = b.readLine()) != null) {
                String line = readLine.trim();
                if (!line.contains("org.glassfish.main")) {
                    String[] lineElements = line.split(":");
                    fourDependencyList.add(lineElements[0] + ":" + lineElements[1]);// + ":" + lineElements[lineElements.length-1]);
                    dependencyFourMap.put(lineElements[0] + ":" + lineElements[1], lineElements[lineElements.length-1]);
                }
            }


            f = new File(dependencyListFiveFile);
            b = new BufferedReader(new FileReader(f));

            ArrayList<String> fiveDependencyList = new ArrayList();

            while ((readLine = b.readLine()) != null) {
                String line = readLine.trim();
                if (!line.contains("org.glassfish.main")) {
                    String [] lineElements = line.split(":");
                    fiveDependencyList.add(lineElements[0] + ":" + lineElements[1]); //+ ":" + lineElements[lineElements.length-1]);
                    dependencyFiveMap.put(lineElements[0] + ":" + lineElements[1], lineElements[lineElements.length-1]);
                }
            }

            System.out.println("*********************************************");
            System.out.println("Modified Dependencies:");
            for (String s : modifiedDependencies) {
               System.out.println(s);
            }

            ArrayList<String> newDependencies = new ArrayList(fiveDependencyList);
            newDependencies.removeAll(fourDependencyList);
            newDependencies.removeAll(modifiedDependencies);


            System.out.println("*********************************************");
            System.out.println("New Dependencies:");
            for (String s : newDependencies) {
               System.out.println(s + ":" + dependencyFiveMap.get(s));
            }

            ArrayList<String> removedDependencies = new ArrayList(fourDependencyList);
            removedDependencies.removeAll(fiveDependencyList);

            System.out.println("*********************************************");
            System.out.println("Dependencies Removed:");
            for (String s : removedDependencies) {
               System.out.println(s + ":" + dependencyFourMap.get(s));
            }


            ArrayList<String> unchangedDependencies = new ArrayList(fourDependencyList);
            unchangedDependencies.removeAll(modifiedDependencies);
            unchangedDependencies.removeAll(removedDependencies);
            System.out.println("*********************************************");
            System.out.println("Unchanged Dependencies:");
            for (String s : unchangedDependencies) {
                System.out.println(s + ":" + dependencyFourMap.get(s));
            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }


    }

}
