import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.StringTokenizer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

public class WithHadoop {
  public static class WordMapper extends Mapper<Object, Text, Text, Text> {
    Text word = new Text();
    Text fileName = new Text();

    @Override
    public void map(Object key, Text value, Context context)
        throws IOException, InterruptedException {
      fileName.set(((FileSplit) context.getInputSplit()).getPath().getName().toString());
      StringTokenizer st = new StringTokenizer(value.toString());
      while (st.hasMoreTokens()) {
        word.set(st.nextToken());
        context.write(word, fileName);
      }
    }
  }

  public static class WordReducer extends Reducer<Text, Text, Text, Text> {
    Text value = new Text();

    @Override
    public void reduce(Text word, Iterable<Text> fileNames, Context context)
        throws IOException, InterruptedException {
      HashMap<String, Integer> map = new HashMap<String, Integer>();
      Iterator<Text> iterator = fileNames.iterator();
      while (iterator.hasNext()) {
        String fileName = iterator.next().toString();
        if (map.containsKey(fileName)) {
          map.replace(fileName, map.get(fileName) + 1);
        } else {
          map.put(fileName, 1);
        }
      }

      StringBuilder sb = new StringBuilder();
      sb.append("=> [ ");
      for (Map.Entry<String, Integer> entry : map.entrySet()) {
        sb.append(String.format("(%s, %d), ", entry.getKey(), entry.getValue()));
      }

      sb.deleteCharAt(sb.length() - 2);
      sb.append("]");
      value.set(sb.toString());
      context.write(word, value);
    }
  }

  public static void main(String[] args)
      throws IOException, ClassNotFoundException, InterruptedException {
    Configuration configuration = new Configuration();
    String[] otherArgs = new GenericOptionsParser(configuration, args).getRemainingArgs();
    if (otherArgs.length != 2) {
      System.err.println("Invalid args detected. Args must be <inputDir> <outputDir>.");
      System.exit(1);
    }

    Job job = Job.getInstance(configuration, "WithHadoop");
    job.setJarByClass(WithHadoop.class);
    job.setMapperClass(WordMapper.class);
    job.setReducerClass(WordReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(Text.class);
    FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
    FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 2);
  }
}
