import java.io.*;
import java.util.*;

class AddSources {

    private static ArrayList<String> newDependencies ;

    private static ArrayList<String> dependenciesRemoved ;

    private static ArrayList<String> dependenciesModified = new ArrayList<>();

    private static Map<String, String> dependencyFiveMap = new HashMap<>();
    private static Map<String, String> dependencyFourMap = new HashMap<>();


    private static String createTag(String projectName, String version, String rawTag) {
        String tag = rawTag;
        if ( tag.contains("$NAME")) {
            tag = tag.replace("$NAME", projectName);
        }

        if (tag.contains("$VERSION")) {
            tag = tag.replace("$VERSION", version);
        }
        return tag;
    }

    private static String getRepoLiteral(String repoType){
        if ("github".equalsIgnoreCase(repoType)) {
            return "get_github_tag";
        }
        else if ("git".equalsIgnoreCase(repoType)) {
            return "get_git_tag";
        }
        else if ("svn".equalsIgnoreCase(repoType)) {
            return "get_svn_tag";
        }
        else if ("curl".equalsIgnoreCase(repoType)) {
            return "get_curl_tag";
        }
        return null;
    }

    private static void generateDependencyDelta (String dependencyListFourFile,
                                                 String dependencyListFiveFile, String dependencyChangesFile ) {

        try {
            String readLine;

            File f;
            BufferedReader b = null;

            f = new File(dependencyChangesFile);
            b = new BufferedReader(new FileReader(f));
            while ((readLine = b.readLine()) != null) {
                String splitWords[] = readLine.split(" ");
                if (!splitWords[0].contains("org.glassfish.main")) {
                    dependenciesModified.add(splitWords[0]);
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

//            System.out.println("*********************************************");
//            System.out.println("Modified Dependencies:");
//            for (String s : dependenciesModified) {
//                System.out.println(s);
//            }

            newDependencies = new ArrayList(fiveDependencyList);
            newDependencies.removeAll(fourDependencyList);
            newDependencies.removeAll(dependenciesModified);


//            System.out.println("*********************************************");
//            System.out.println("New Dependencies:");
//            for (String s : newDependencies) {
//                System.out.println(s + ":" + dependencyFiveMap.get(s));
//            }

            dependenciesRemoved = new ArrayList(fourDependencyList);
            dependenciesRemoved.removeAll(fiveDependencyList);

//            System.out.println("*********************************************");
//            System.out.println("Dependencies Removed:");
//            for (String s : dependenciesRemoved) {
//                System.out.println(s + ":" + dependencyFourMap.get(s));
//            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public static void main(String args[]) {
        try {
            String present_dir = System.getProperty("present_directory") + "/";
            String sourceListPath = present_dir + args[0];
            String dependencyListPath = present_dir + args[1];
            String dependencyListOfGF412Path = present_dir + args[2];
            String dependencyChangesPath = present_dir + args[3];
            String buildOrderPath = present_dir + args[4];
            String scriptGeneratedPath = present_dir + args[5];

            generateDependencyDelta(dependencyListOfGF412Path, dependencyListPath, dependencyChangesPath);

            String readLine;
            File f = new File(dependencyListPath);
            BufferedReader b = new BufferedReader(new FileReader(f));

            f = new File(buildOrderPath);
            b = new BufferedReader(new FileReader(f));

            ArrayList<String> orderedBuildSources = new ArrayList<>();

            while ((readLine = b.readLine()) != null) {
                String line = readLine.trim();
                orderedBuildSources.add(line);
            }

            ArrayList<String> dependencyList = new ArrayList();
            Set<String> dependencies = new HashSet();
            Map<String, String> dependencyVersionMap = new HashMap();

            f = new File(dependencyListPath);
            b = new BufferedReader(new FileReader(f));

            while ((readLine = b.readLine()) != null) {
                String line = readLine.trim();
                String[] lineElements = line.split(":");
                dependencyVersionMap.put(lineElements[0] + ":" + lineElements[1], lineElements[3]);

            }

            f = new File(sourceListPath);
            b = new BufferedReader(new FileReader(f));

            ArrayList<String> sourceList = new ArrayList();

            while ((readLine = b.readLine()) != null) {
                sourceList.add(readLine);
            }

            PrintWriter pw = new PrintWriter(new BufferedWriter(new FileWriter(
                    new File(scriptGeneratedPath),true)));

            for (String s : orderedBuildSources) {
                String dependency = s.split(" ")[1];
                String version = dependencyVersionMap.get(dependency);
                if (!dependenciesRemoved.contains(dependency)) {
                    for (String source : sourceList) {
                        if (source.contains(dependency)) {
                            String[] sourceMetadata = source.split(" ");

                            String projectName = sourceMetadata[1];
                            String url = null;
                            String rawTag = null ;
                            String sourceType = null;
                            String repoType = null;

                            if (sourceMetadata.length >= 6) {
                                url = sourceMetadata[2];
                                rawTag = sourceMetadata[3];
                                sourceType = sourceMetadata[4];
                                repoType = sourceMetadata[5];
                            }
                            String tag = null;
                            if (rawTag != null && projectName !=null && version !=null) {
                                tag = createTag(projectName, version, rawTag);

                                if (tag.equalsIgnoreCase("NA")) {
                                   // System.out.println("Tag for dependency: " + dependency + ", project name: " + projectName + " needs to be added.");
                                }
                            }


                            //System.out.println(getRepoLiteral(repoType) + " " + projectName + " " + version + " " + url + " " + tag + " " + sourceType);
                            pw.print(getRepoLiteral(repoType) + " " + projectName + " " + version + " " + url + " " + tag + " " + sourceType);
                            pw.println();
                            break;

                        }
                    }
                }
                else {
                    System.out.println(dependency + " removed.");
                }

            }

	    System.out.println("Add souce URL for new dependencies: ");
            for (String dependency : newDependencies) {
                System.out.println(dependency);
            }


            /*

            dependencies = dependencyVersionMap.keySet();



            for (String d : dependencies) {
                String version = dependencyVersionMap.get(d);
                for (String  s : sourceList) {
                    if (s.contains(d)) {
                        String[] sourceMetadata = s.split(" ");

                            String projectName = sourceMetadata[1];
                            String url = sourceMetadata[2];
                            String rawTag = sourceMetadata[3];
                            String sourceType = sourceMetadata[4];
                            String repoType = sourceMetadata[5];

                            String tag = createTag(projectName, version, rawTag);

                            if (tag == null) {
                                System.out.println("Tag for dependency: " + d + "name: " + projectName + " needs to be added.");
                            }
                            System.out.println(getRepoLiteral(repoType) + " " + projectName + " " + version + " " + url + " " + tag + " " + sourceType);
                            pw.print(getRepoLiteral(repoType) + " " + projectName + " " + version + " " + url + " " + tag + " " + sourceType);
                            break;

                    }
                }
            }*/
            pw.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

}
