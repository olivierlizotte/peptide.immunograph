package graphDB.explore.tools;

import java.util.*;
import java.util.concurrent.*;

public class Parallel
{
	static final int iCPU = Runtime.getRuntime().availableProcessors();

	public static <T> void ForEach(Iterable <T> parameters,
	                   final LoopBody<T> loopBody)
	{
	    ExecutorService executor = Executors.newFixedThreadPool(iCPU);
	    List<Future<?>> futures  = new LinkedList<Future<?>>();  //LinkedList()<Future<?>>();
	
	    for (final T param : parameters)
	    {
	        Future<?> future = executor.submit(new Runnable()
	        {
	            public void run() { loopBody.run(param); }
	        });
	
	        futures.add(future);
	    }
	
	    for (Future<?> f : futures)
	    {
	        try   { f.get(); }
	        catch (InterruptedException e) { } 
	        catch (ExecutionException   e) { }         
	    }
	
	    executor.shutdown();     
	}	
	
	public interface LoopBody <T>
	{
	    void run(T i);
	}
}
/*
public ParallelTest()
{
    k = 0;
    Parallel.For(0, 10, new LoopBody <Integer>()
    {
        public void run(Integer i)
        {
            k += i;
            System.out.println(i);          
        }
    });
    System.out.println("Sum = "+ k);
}//*/

