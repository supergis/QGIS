
/**
 There are two possibilities how to use this class:
 1. static call to QgsVectorFileWriter::writeAsShapefile(...) which saves the whole vector layer
 2. create an instance of the class and issue calls to addFeature(...)

 Currently supports only writing to shapefiles, but shouldn't be a problem to add capability
 to support other OGR-writable formats.
 */
class QgsVectorFileWriter
{
%TypeHeaderCode
#include <qgsvectorfilewriter.h>
#include <qgsfield.h>
%End

  public:
    enum OptionType
    {
      Set,
      String,
      Int,
      Hidden
    };

    class Option
    {
      public:
        Option( const QString& docString, QgsVectorFileWriter::OptionType type );
        virtual ~Option();

        QString docString;
        QgsVectorFileWriter::OptionType type;
    };

    class SetOption : QgsVectorFileWriter::Option
    {
      public:
        SetOption( const QString& docString, const QStringList& values, const QString& defaultValue, bool allowNone = false );

        QSet<QString> values;
        QString defaultValue;
        bool allowNone;
    };

    class StringOption: QgsVectorFileWriter::Option
    {
      public:
        StringOption( const QString& docString, const QString& defaultValue = QString() );

        QString defaultValue;
    };

    class IntOption: QgsVectorFileWriter::Option
    {
      public:
        IntOption( const QString& docString, int defaultValue );

        int defaultValue;
    };

    class BoolOption : QgsVectorFileWriter::SetOption
    {
      public:
        BoolOption( const QString& docString, bool defaultValue );
    };

    class HiddenOption : QgsVectorFileWriter::Option
    {
      public:
        HiddenOption( const QString& value );

        QString mValue;
    };

    struct MetaData
    {
      MetaData();

      MetaData( const QString& longName, const QString& trLongName, const QString& glob, const QString& ext, const QMap<QString, QgsVectorFileWriter::Option*>& driverOptions, const QMap<QString, QgsVectorFileWriter::Option*>& layerOptions );

      QString longName;
      QString trLongName;
      QString glob;
      QString ext;
      QMap<QString, QgsVectorFileWriter::Option*> driverOptions;
      QMap<QString, QgsVectorFileWriter::Option*> layerOptions;
    };

    enum WriterError
    {
      NoError,
      ErrDriverNotFound,
      ErrCreateDataSource,
      ErrCreateLayer,
      ErrAttributeTypeUnsupported,
      ErrAttributeCreationFailed,
      ErrProjection,
      ErrFeatureWriteFailed,
      ErrInvalidLayer,
    };

    enum SymbologyExport
    {
      NoSymbology, //export only data
      FeatureSymbology, //Keeps the number of features and export symbology per feature
      SymbolLayerSymbology //Exports one feature per symbol layer (considering symbol levels)
    };

    /** Write contents of vector layer to an (OGR supported) vector formt
    @param layer layer to write
    @param fileName file name to write to
    @param fileEncoding encoding to use
    @param destCRS pointer to CRS to reproject exported geometries to
    @param driverName OGR driver to use
    @param onlySelected write only selected features of layer
    @param errorMessage pointer to buffer fo error message
    @param datasourceOptions list of OGR data source creation options
    @param layerOptions list of OGR layer creation options
    @param skipAttributeCreation only write geometries
    @param newFilename QString pointer which will contain the new file name created (in case it is different to fileName).
    @param symbologyExport symbology to export
    @param symbologyScale scale of symbology
    @param filterExtent if not a null pointer, only features intersecting the extent will be saved (added in QGIS 2.4)
    allows for conversion of geometryless tables to null geometries, etc (added in QGIS 2.14)
    @param forceMulti set to true to force creation of multi* geometries (added in QGIS 2.14)
    @param includeZ set to true to include z dimension in output. This option is only valid if overrideGeometryType is set. (added in QGIS 2.14)
    */
    static WriterError writeAsVectorFormat( QgsVectorLayer* layer,
                                            const QString& fileName,
                                            const QString& fileEncoding,
                                            const QgsCoordinateReferenceSystem *destCRS,
                                            const QString& driverName = "ESRI Shapefile",
                                            bool onlySelected = false,
                                            QString *errorMessage = 0,
                                            const QStringList &datasourceOptions = QStringList(),
                                            const QStringList &layerOptions = QStringList(),
                                            bool skipAttributeCreation = false,
                                            QString *newFilename = 0,
                                            SymbologyExport symbologyExport = NoSymbology,
                                            double symbologyScale = 1.0,
                                            const QgsRectangle* filterExtent = 0,
                                            QgsWKBTypes::Type overrideGeometryType = QgsWKBTypes::Unknown,
                                            bool forceMulti = false,
                                            bool includeZ = false
                                          );

    /** Writes a layer out to a vector file.
     * @param layer layer to write
     * @param fileName file name to write to
     * @param fileEncoding encoding to use
     * @param ct
     * @param driverName OGR driver to use
     * @param onlySelected write only selected features of layer
     * @param errorMessage pointer to buffer fo error message
     * @param datasourceOptions list of OGR data source creation options
     * @param layerOptions list of OGR layer creation options
     * @param skipAttributeCreation only write geometries
     * @param newFilename QString pointer which will contain the new file name created (in case it is different to fileName).
     * @param symbologyExport symbology to export
     * @param symbologyScale scale of symbology
     * @param filterExtent if not a null pointer, only features intersecting the extent will be saved (added in QGIS 2.4)
     * @param overrideGeometryType set to a valid geometry type to override the default geometry type for the layer. This parameter
     * allows for conversion of geometryless tables to null geometries, etc (added in QGIS 2.14)
     * @param forceMulti set to true to force creation of multi* geometries (added in QGIS 2.14)
     * @param includeZ set to true to include z dimension in output. This option is only valid if overrideGeometryType is set. (added in QGIS 2.14)
     * @note added in v2.2
     */
    static WriterError writeAsVectorFormat( QgsVectorLayer* layer,
                                            const QString& fileName,
                                            const QString& fileEncoding,
                                            const QgsCoordinateTransform* ct,
                                            const QString& driverName = "ESRI Shapefile",
                                            bool onlySelected = false,
                                            QString *errorMessage = 0,
                                            const QStringList &datasourceOptions = QStringList(),
                                            const QStringList &layerOptions = QStringList(),
                                            bool skipAttributeCreation = false,
                                            QString *newFilename = 0,
                                            SymbologyExport symbologyExport = NoSymbology,
                                            double symbologyScale = 1.0,
                                            const QgsRectangle* filterExtent = 0,
                                            QgsWKBTypes::Type overrideGeometryType = QgsWKBTypes::Unknown,
                                            bool forceMulti = false,
                                            bool includeZ = false
                                          );

    /** Create shapefile and initialize it */
    QgsVectorFileWriter( const QString& vectorFileName,
                         const QString& fileEncoding,
                         const QgsFields& fields,
                         QGis::WkbType geometryType,
                         const QgsCoordinateReferenceSystem* srs,
                         const QString& driverName = "ESRI Shapefile",
                         const QStringList &datasourceOptions = QStringList(),
                         const QStringList &layerOptions = QStringList(),
                         QString *newFilename = 0,
                         QgsVectorFileWriter::SymbologyExport symbologyExport = QgsVectorFileWriter::NoSymbology
                       );

    /** Returns map with format filter string as key and OGR format key as value*/
    static QMap< QString, QString> supportedFiltersAndFormats();

    /** Returns driver list that can be used for dialogs. It contains all OGR drivers
     * + some additional internal QGIS driver names to distinguish between more
     * supported formats of the same OGR driver
     */
    static QMap< QString, QString> ogrDriverList();

    /** Returns filter string that can be used for dialogs*/
    static QString fileFilterString();

    /** Creates a filter for an OGR driver key*/
    static QString filterForDriver( const QString& driverName );

    /** Converts codec name to string passed to ENCODING layer creation option of OGR Shapefile*/
    static QString convertCodecNameForEncodingOption( const QString &codecName );

    /** Checks whether there were any errors in constructor */
    WriterError hasError();

    /** Retrieves error message */
    QString errorMessage();

    /** Add feature to the currently opened shapefile */
    bool addFeature( QgsFeature& feature, QgsFeatureRendererV2* renderer = 0, QGis::UnitType outputUnit = QGis::Meters );

    //! @note not available in python bindings
    // QMap<int, int> attrIdxToOgrIdx();

    /** Close opened shapefile for writing */
    ~QgsVectorFileWriter();

    /** Delete a shapefile (and its accompanying shx / dbf / prf)
     * @param theFileName /path/to/file.shp
     * @return bool true if the file was deleted successfully
     */
    static bool deleteShapeFile( const QString& theFileName );

    SymbologyExport symbologyExport() const;
    void setSymbologyExport( SymbologyExport symExport );

    double symbologyScaleDenominator() const;
    void setSymbologyScaleDenominator( double d );

    static bool driverMetadata( const QString& driverName, MetaData& driverMetadata );

  protected:
    //! @note not available in python bindings
    // OGRGeometryH createEmptyGeometry( QGis::WkbType wkbType );
};
