cdef extern from "qrencode.h":
    int QR_ECLEVEL_L
    int QR_ECLEVEL_M
    int QR_ECLEVEL_Q
    int QR_ECLEVEL_H
    
    int QR_MODE_NUM
    int QR_MODE_AN
    int QR_MODE_8
    int QR_MODE_KANJI
    
    ctypedef struct QRcode:
        int version
        int width
        unsigned char *data
    
    QRcode *QRcode_encodeString(char *string, int version, int level, int hint, int casesensitive)


cdef class Encoder:
    EC_L = QR_ECLEVEL_L
    EC_M = QR_ECLEVEL_M
    EC_Q = QR_ECLEVEL_Q
    EC_H = QR_ECLEVEL_H
    
    MODE_NUM = QR_MODE_NUM
    MODE_AN = QR_MODE_AN
    MODE_8 = QR_MODE_8
    MODE_KANJI = QR_MODE_KANJI
    
    default_options = {
        'mode' : QR_MODE_8,
        'ec_level': QR_ECLEVEL_L,
        'width': 400,
        'border': 10,
        'version': 5,
        'case_sensitive': True
    }
    
    def __cinit__(self):
        pass
    
    def __dealloc__(self):
        pass
    
    def encode_matrix(self, char *text, options={}):
        '''
        Returns (version, width, data).  Does not create an image.  `data` will
        be a list of length (width*width), containing one item for each 
        "module" (in QR code parlance, a module is an atomic black/white output
        square).
        
        Honors options 
            - version
            - mode
            - ec_level
            - case_sensitive        
        
        Only the least significant bit of each integer in `data` should be 
        considered for normal applications: 1 means black, 0 means white.
        
         MSB 76543210 LSB
             |||||||`- 1=black/0=white
             ||||||`-- data and ecc code area
             |||||`--- format information
             ||||`---- version information
             |||`----- timing pattern
             ||`------ alignment pattern
             |`------- finder pattern and separator
             `-------- non-data modules (format, timing, etc.)        
        '''
        cdef QRcode *_c_code
        cdef unsigned char *data
        
        opt = self.default_options
        opt.update(options)
        
        v = opt.get('version')
        mode = opt.get('mode')
        ec_level = opt.get('ec_level')
        case_sensitive = opt.get('case_sensitive')
       
        # encode the text as a QR code
        str_copy = text
        str_copy = str_copy + '\0'
        _c_code = QRcode_encodeString(str_copy, int(v), int(ec_level), int(mode), int(case_sensitive))
        version = _c_code.version
        width = _c_code.width
        data = _c_code.data
        return version, width, [ data[i] for i in range(width * width) ]
    
    def encode(self, char *text, options={}):
        from ImageOps import expand
        from Image import fromstring
        
        cdef QRcode *_c_code
        cdef unsigned char *data
        
        opt = self.default_options
        opt.update(options)
        
        border = opt.get('border')
        w = opt.get('width') - (border * 2)
        v = opt.get('version')
        mode = opt.get('mode')
        ec_level = opt.get('ec_level')
        case_sensitive = opt.get('case_sensitive')
       
        # encode the test as a QR code
        str_copy = text
        str_copy = str_copy + '\0'
        _c_code = QRcode_encodeString(str_copy, int(v), int(ec_level), int(mode), int(case_sensitive))
        version = _c_code.version
        width = _c_code.width
        data = _c_code.data
        
        rawdata = ''
        dotsize = w / width
        realwidth = width * dotsize
        
        # build raw image data
        for y in range(width):
            line = ''
            for x in range(width):
                if data[y * width + x] % 2:
                    line += dotsize * chr(0)
                else:
                    line += dotsize * chr(255)
            lines = dotsize * line
            rawdata += lines
        
        # create PIL image w/ border
        image = expand(fromstring('L', (realwidth, realwidth), rawdata), border, 255)
        
        return image
