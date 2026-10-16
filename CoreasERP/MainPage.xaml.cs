namespace CoreasERP;

public partial class MainPage : ContentPage
{
	public MainPage()
	{
		InitializeComponent();

#if WINDOWS
		blazorWebView.BlazorWebViewInitialized += (s, e) =>
		{
			e.WebView.CoreWebView2.Settings.AreBrowserAcceleratorKeysEnabled = true;
			e.WebView.CoreWebView2.Settings.AreDevToolsEnabled = true;
		};
#endif
	}
}
