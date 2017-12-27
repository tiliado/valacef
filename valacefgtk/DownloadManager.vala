namespace CefGtk {

public class DownloadManager : GLib.Object {
    private unowned WebView web_view;
    private HashTable<string, Task> tasks;
    private uint next_task_id = 0;
    
    public DownloadManager(WebView web_view) {
        this.web_view = web_view;
        tasks = new HashTable<string, Task>(str_hash, str_equal);
    }
    
    public bool start_download(string uri) {
        Cef.assert_browser_ui_thread();
        return web_view.start_download(uri);
    }
    
    public async bool download_file(string uri, string destination, Cancellable? cancellable=null) {
        Cef.assert_browser_ui_thread();
        string id_uri = null;
        uint id = 0;
        do {
            id = next_task_id++;  // uint wraps to zero
            id_uri = task_id_str(id);
        } while (id_uri in tasks);
        if (!start_download(uri)) {
            return false;
        }
        var task = new Task(id, uri, destination, download_file.callback, cancellable);
        tasks[id_uri] = task;
        yield;
        return task.result;
    }
    
    internal void on_before_download(Cef.DownloadItem item, string? suggested_name,
    Cef.BeforeDownloadCallback handler) {
        Cef.assert_browser_ui_thread();
        var download_id = item.get_id();
        var uri = item.get_original_url();
        assert(!(download_id_str(download_id) in tasks));
        var iter = HashTableIter<string, Task>(tasks);
        unowned Task task;
        while (iter.next(null, out task)) {
            if (!task.claimed && task.uri == uri) {
                task.claim(download_id);
                tasks[download_id_str(download_id)] = task;
                Cef.String _destination = {};
                Cef.set_string(&_destination, task.destination);
                handler.cont(&_destination, 0);
                return;
            }
        }
    }
    
    internal void on_download_updated(Cef.DownloadItem item, Cef.DownloadItemCallback handler) {
        Cef.assert_browser_ui_thread();
        var download_id = download_id_str(item.get_id());
        var task = tasks[download_id];
        if (task != null) {
            if (item.is_complete() + item.is_canceled() != 0) {
                task.finished(!((bool) item.is_canceled()));
                tasks.remove(task_id_str(task.task_id));
                tasks.remove(download_id);
            } else if (task.is_cancelled()) {
                tasks.remove(task_id_str(task.task_id));
                tasks.remove(download_id);
                handler.cancel();
                task.finished(false);
            }
        }
    }
    
    private inline static string task_id_str(uint task_id) {
        return "task:%u".printf(task_id);
    }
    
    private inline static string download_id_str(uint download_id) {
        return "download:%u".printf(download_id);
    }
    
    private class Task {
        public uint task_id;
        public uint download_id = 0;
        public string uri;
        public bool claimed = false;
        public string destination;
        public Cancellable? cancellable;
        public bool result = false;
        public SourceFunc callback;
        
        public Task(uint task_id, string uri, string destination, owned SourceFunc callback,
        Cancellable? cancellable) {
            this.task_id = task_id;
            this.uri = uri;
            this.destination = destination;
            this.cancellable = cancellable;
            this.callback = (owned) callback;
        }
        
        public void claim(uint download_id) {
            assert(!claimed);
            this.download_id = download_id;
            this.claimed = true;
        }
        
        public void finished(bool result) {
            Cef.assert_browser_ui_thread();
            this.result = result;
            Idle.add((owned) callback);
            callback = null;
        }
        
        public bool is_cancelled() {
            return cancellable != null && cancellable.is_cancelled();
        }
    }
}

} // namespace CefGtk
