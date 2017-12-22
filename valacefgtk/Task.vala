namespace CefGtk {

public delegate void TaskFunc();

public class Task {
    public static bool post(Cef.ThreadId thread_id, owned TaskFunc func) {
        return (bool) Cef.post_task(thread_id, new CefTask(new Task(thread_id, (owned) func)));
    }
    
    public static bool schedule(Cef.ThreadId thread_id, int64 delay_ms, owned TaskFunc func) {
        return (bool) Cef.post_delayed_task(thread_id, new CefTask(new Task(thread_id, (owned) func)), delay_ms);
    }
    
    private TaskFunc func;
    private Cef.ThreadId thread_id;
    
    private Task(Cef.ThreadId thread_id, owned TaskFunc func) {
        this.thread_id = thread_id;
        this.func = (owned) func;
    }
    
    private void execute() {
        assert(Cef.currently_on(thread_id) > 0);
        func();
    }
    
    private class CefTask : Cef.TaskRef {
        public CefTask(Task task) {
            base();
            priv_set("task", task);
        
            /**
             * Method that will be executed on the target thread.
             */
            /*void*/ vfunc_execute = (self) => {
                ((Cef.TaskRef) self).priv_get<Task>("task").execute();
                ((Cef.TaskRef) self).priv_del("task");
            };
        }
    }
}

} // namespace CefGtk
