/// Configuración centralizada de mapas y proveedores de teselas (Tile Layers).
class MapConfig {
  /// API Key opcional inyectable por entorno (--dart-define=CARTO_API_KEY=xxx)
  /// Si no se provee, consume el servicio estándar de CartoDB sin exponer credenciales.
  static const String cartoApiKey = String.fromEnvironment(
    'CARTO_API_KEY',
    defaultValue: '',
  );

  /// Proveedor Google Maps (Estilo Oficial 1:1)
  /// Proporciona la apariencia exacta de Google Maps: calles con colores Google,
  /// autopistas en amarillo, áreas verdes y tipografía oficial con soporte CORS.
  static const String googleMapsTileUrl =
      'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
  static const List<String> googleMapsSubdomains = ['0', '1', '2', '3'];

  /// Proveedor CartoDB Voyager (Retina @2x)
  static String get cartoVoyagerTileUrl => cartoApiKey.isNotEmpty
      ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png?api_key=$cartoApiKey'
      : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';
  static const List<String> cartoSubdomains = ['a', 'b', 'c', 'd'];
}
