cdef extern from "Python.h":
    int PY_MAJOR_VERSION

cdef extern from "stdlib.h":
    void free(void *ptr)

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
    
    QRcode *QRcode_encodeString(
        char *string, 
        int version, 
        int level, 
        int hint, 
        int casesensitive)


EC_L = QR_ECLEVEL_L
EC_M = QR_ECLEVEL_M
EC_Q = QR_ECLEVEL_Q
EC_H = QR_ECLEVEL_H

EC_DEFAULT = EC_M

VERSION_DEFAULT = 0 # the C library chooses the minimum version for given input
    
cdef QRcode *encode_string(
    text, 
    int ec_level, 
    int version):
    '''
    encode the given string as QR code.
    '''
    
    if isinstance(text, unicode):
        text = text.encode('UTF-8')
    elif PY_MAJOR_VERSION < 3 and isinstance(text, str):
        text.decode('UTF-8')
    else:
        raise ValueError('requires text input, got %s' % type(text))
    
    # encode the text as a QR code
    str_copy = text + '\0'
    return QRcode_encodeString(
        str_copy, 
        version, 
        ec_level, 
        QR_MODE_8, 
        1 # case-sensitive
        )    

def encode(
    text, 
    int ec_level=EC_DEFAULT, 
    int version=VERSION_DEFAULT):
    '''
    Encode the given text as a QR Code.  Return the QR Code as a bitmap
    represented as a list of lists of boolean values.  I.e., 
    [ [bool, ... ], ... ].  True is black; False is white.
    '''
    cdef QRcode *code
    
    # encode the text as a QR code
    null_terminated_text = text + '\0'
    code = encode_string(
        null_terminated_text, 
        version,
        ec_level)
    cdef int width = code.width
    cdef unsigned char* data = code.data 
    
    rows = [] # a list of tuples of bool; the bitmap result-to-be
    cdef int i, start, end
    for i in range(code.width):
        start = i * width   # first index in this row
        end = start + width # first index AFTER this row
        rows.append([ bool(data[i] & 1) for i in range(start, end) ])
        
    free(code)
    return rows
