import java.io.*;
import java.nio.file.*;
import java.text.Normalizer;
import java.util.*;
import java.util.stream.Collectors;

public class rmAccents {

    // Function to remove words with special characters
    public static List<String> filterWords(List<String> words) {
        List<String> filteredWords = new ArrayList<>();

        for (String word : words) {
            // Normalize to decompose accents
            String normalized = Normalizer.normalize(word, Normalizer.Form.NFD);
            // Check if the word contains only ASCII letters after normalization
            if (normalized.matches("^[a-zA-Z]+$")) {
                filteredWords.add(word);
            }
        }
        return filteredWords;
    }

    public static void main(String[] args) {
        // Specify the input and output file paths
        String inputFilePath = "spanish_words.json";  // Replace with your input file path
        String outputFilePath = "processed_spanish_words.json";  // Replace with your desired output file path

        try {
            // Read all lines from the input file
            String content = Files.readString(Paths.get(inputFilePath));

            // Parse the file content into a list of words
            // Assuming the file content is in a JSON-like array format: ["word1", "word2", ...]
            List<String> words = Arrays.stream(content.replace("[", "").replace("]", "").replace("\"", "").split(","))
                                       .map(String::trim)
                                       .collect(Collectors.toList());

            // Filter the words
            List<String> filteredWords = filterWords(words);

            // Convert the filtered words back to JSON-like array format
            String outputContent = "[" + filteredWords.stream()
                                                      .map(word -> "\"" + word + "\"")
                                                      .collect(Collectors.joining(",")) + "]";

            // Write the filtered content back to the output file
            Files.writeString(Paths.get(outputFilePath), outputContent);

            System.out.println("Filtered words have been saved to: " + outputFilePath);
        } catch (IOException e) {
            System.err.println("Error processing file: " + e.getMessage());
        }
    }
}
