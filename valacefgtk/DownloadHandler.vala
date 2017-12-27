namespace CefGtk {

public class DownloadHandler : Cef.DownloadHandlerRef {
    public DownloadHandler(DownloadManager manager) {
        base();
        priv_set<unowned DownloadManager>("manager", manager);
         /**
         * Called before a download begins. |suggested_name| is the suggested name for
         * the download file. By default the download will be canceled. Execute
         * |callback| either asynchronously or in this function to continue the
         * download if desired. Do not keep a reference to |download_item| outside of
         * this function.
         */
        /*void*/ vfunc_on_before_download = (self, /*Browser*/ browser, /*DownloadItem*/ download_item,
        /*String*/ suggested_name, /*BeforeDownloadCallback*/ callback) => {
            Cef.assert_browser_ui_thread();
            ((Cef.DownloadHandlerRef) self).priv_get<DownloadManager>("manager").on_before_download(
                download_item, Cef.get_string(suggested_name), callback);
        };

        /**
         * Called when a download's status or progress information has been updated.
         * This may be called multiple times before and after on_before_download().
         * Execute |callback| either asynchronously or in this function to cancel the
         * download if desired. Do not keep a reference to |download_item| outside of
         * this function.
         */
        /*void*/ vfunc_on_download_updated = (self, /*Browser*/ browser, /*DownloadItem*/ download_item,
        /*DownloadItemCallback*/ callback) => {
            Cef.assert_browser_ui_thread();
            ((Cef.DownloadHandlerRef) self).priv_get<DownloadManager>("manager").on_download_updated(
                download_item, callback);
        };
    }
}

} // namespace CefGtk
