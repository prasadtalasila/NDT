x2package nodeselector;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Random;
import java.util.Scanner;
import java.util.StringTokenizer;

public class RandomSelector {
	 static int randInt(int min, int max) {

	    // NOTE: Usually this should be a field rather than a method
	    // variable so that it is not re-seeded every call.
	    Random rand = new Random();
	    // nextInt is normally exclusive of the top value,
	    // so add 1 to make it inclusive
	    int randomNum = rand.nextInt((max - min) + 1) + min;

	    return randomNum;
	}	
	static void sort(int array[],int size){
		int swap;
	    for (int c = 0; c < ( size - 1 ); c++) {
	      for (int d = 0; d < size - c - 1; d++) {
	        if (array[d] > array[d+1]) 
	        {
	          swap       = array[d];
	          array[d]   = array[d+1];
	          array[d+1] = swap;
	        }
	      }
	    }
	}
	
	public static void main(String args[]){
		System.out.println("Please enter three weighted parameters such that their sum is less than one. The fourth will automatically be 1 minus the sum ");
		System.out.println("First for Throughput, second for Jitter, third for Latency.");
		System.out.println("Enter 0 to choose parameters. Enter 1 to select default paramaters(1/4,1/4,1/4,1/4).");
		Scanner s = new Scanner(System.in);
		int choice  = s.nextInt();
		double param1 ;
		double param2 ;
		double param3 ;
		if(choice ==0){
			param1 = s.nextDouble();
			if(param1>1)
		{
			System.out.println("Please enter 3 parameters whose sum is less than one ");
			System.exit(0);
		}
			param2 = s.nextDouble();
		if(param1 + param2 >1)
		{
			System.out.println("Please enter 3 parameters whose sum is less than one ");
			System.exit(0);
		}
		param3 = s.nextDouble();
		if(param1 + param2 + param3>1)
			{
			System.out.println("Please enter 3 parameters whose sum is less than one ");
			System.exit(0);
			}
		}
		else if(choice ==1)
		{
			param1 = 0.25;
			param2 = 0.25;
			param3 = 0.25;
		}
		else
		{
			param1 = param2 = param3 =0;
			System.out.println("Please enter 0 or 1 as choice");
			System.exit(0);
		}
		double param4 = 1 - param1 - param2 - param3;
		try{
		String csvFile = "/home/sukanto/Downloads/SOP/2010_11.csv";
		BufferedReader br = new BufferedReader(new FileReader(csvFile));
		BufferedReader br2 = new BufferedReader(new FileReader(csvFile));
		String line = "";
	    int lineNumber = 0,lineNumber2 =0; 	    
	    double values[][] = new double[100][100];
	    double values2[][] = new double[100][100];
	    String IP [] = new String[51];
	    
	    while ((line = br.readLine())!= null) {
	         lineNumber++;
	         //tells total no. of lines in file
	    }
	    
	    int randomNumbers[] =new int[51];  //change size depending on number of random nos. needed
	    for(int i=0;i<51;i++)
	    {
	    	randomNumbers[i]= randInt(2,lineNumber);
	    }
	    sort(randomNumbers,50);
	    int i=0;
	    while((line = br2.readLine())!=null) {
	    	lineNumber2++;
	    	if(lineNumber2 == randomNumbers[i]){
	    		//st = new StringTokenizer(line, ",");//use comma as token separator
	    		//values[i][counter]=Double.parseDouble(st.nextToken());
	    		IP[i] = line.split(",")[3];//IP
	 
	    		values[i][0] = Double.parseDouble(line.split(",")[2]);//Throughput
	    		values[i][1] = Double.parseDouble(line.split(",")[5]);//Jitter
	    		values[i][2] = Double.parseDouble(line.split(",")[6]);//Latency
	    		values[i][3] = Double.parseDouble(line.split(",")[7]);//Reliability
	    		values[i][4] = Double.parseDouble(line.split(",")[0]);//Lat
	    		values[i][5] = Double.parseDouble(line.split(",")[1]);//Long
	    		i++;
	    		}
	    	 }
	    int k;
	    double max[]= new double[4];
	    double min[]= {999999,999999,999999,999999};
	    for(k=1;k<50;k++)
	    {
	    	if(values[k][0]>max[0])
	    		max[0]= values[k][0];
	    	if(values[k][1]>max[1])
	    		max[1]= values[k][1];
	    	if(values[k][2]>max[2])
	    		max[2]= values[k][2];
	    	if(values[k][3]>max[3])
	    		max[3]= values[k][3];
	    	if(values[k][0]<min[0])
	    		min[0]= values[k][0];
	    	if(values[k][1]<min[1])
	    		min[1]= values[k][1];
	    	if(values[k][2]<min[2])
	    		min[2]= values[k][2];
	    	if(values[k][3]<min[3])
	    		min[3]= values[k][3];
	    }
	    for(k=1;k<50;k++)
	    {
	    	values2[k][0] = (values[k][0] - min[0])/(max[0]- min[0]);
	    	values2[k][1] = (max[1] - values[k][1])/(max[1]- min[1]);
	    	values2[k][2] = (max[2] - values[k][2])/(max[2]- min[2]);
	    	values2[k][3] = (max[3] - values[k][3])/(max[3]- min[3]);
	    }
	    double comparer[]= new double[100];
	    for(k=1;k<50;k++)
	    {
	    	comparer[k]= (values2[k][0]*param1) + (values2[k][1]*param2) + (values2[k][2]*param3) + (values2[k][3]*param4) ;
	    }
	    double maximus =0;
	    int result=0;
	    for(k=1;k<50;k++)
	    {
	    		if(comparer[k]>maximus){
	    			maximus = comparer[k];
	    			result = k;
	    		}
	    }
	    //System.out.println(values[49][2]);
	    System.out.println("The source node is : "+IP[0]+"\n Throughput :"+values[0][0]+"\nJitter :"+values[0][1]+"\nLatency :"+values[0][2]+"\nReliability :"+values[0][3]+"\nLatitude :"+values[0][4]+"\nLongitude :"+values[0][5]+"\n");
	    System.out.println("The best node is :"+ IP[result] +"\n Throughput :"+values[result][0]+"\nJitter :"+values[result][1]+"\nLatency :"+values[result][2]+"\nReliability :"+values[result][3]+"\nLatitude :"+values[result][4]+"\nLongitude :"+values[result][5]+"\n");
	    
	    br2.close();
	    br.close();
		}
		catch (Exception e) {
	       System.err.println("CSV file cannot be read : " + e);
	     }
	}
}
