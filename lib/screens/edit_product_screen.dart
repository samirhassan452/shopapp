import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/auth_provider.dart';
import 'package:real_shop/providers/single_product_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct = SingleProductProvider(
    id: null,
    title: '',
    description: '',
    price: 0.0,
    imageUrl: '',
  );
  var _initialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  File _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _loadImage = false;
  bool _showImageErrMsg = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findProductById(productId);
        _initialValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionNode.dispose();
    _imageUrlController.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              _imageUrlController.text.endsWith('.jpg') &&
              _imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (_editedProduct.id == null) {
      if (_pickedImage == null) {
        setState(() {
          _showImageErrMsg = true;
        });
        return;
      } else {
        setState(() {
          _showImageErrMsg = false;
        });
      }
    }

    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    // in case of we need to edit product not add new product
    if (_editedProduct.id != null) {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (err) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occurred!"),
            content: Text("Something went wrong"),
            actions: [
              FlatButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Okay!"),
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_editedProduct.id == null ? 'Add' : 'Edit'} Product"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initialValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      // instead of show Done in Keyboard when click on field, we will show Next
                      // to move to next field
                      textInputAction: TextInputAction.next,
                      // when finish this filed not all form, then move to next
                      onFieldSubmitted: (_) {
                        // when finish this field, move to next field which is price field
                        // and this is reason for using FocusNode
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'please provide a value';
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = SingleProductProvider(
                          id: _editedProduct.id,
                          title: val,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      // instead of show Done in Keyboard when click on field, we will show Next
                      // to move to next field
                      textInputAction: TextInputAction.next,
                      // when finish this filed not all form, then move to next
                      onFieldSubmitted: (_) {
                        // when finish this field, move to next field which is price field
                        // and this is reason for using FocusNode
                        FocusScope.of(context).requestFocus(_descriptionNode);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'please provide a value';
                        if (double.tryParse(val) == null)
                          return 'please provide a valid price!';
                        if (double.parse(val) <= 0)
                          return 'please enter price greater than 0';
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = SingleProductProvider(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(val),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionNode,
                      // instead of show Done in Keyboard when click on field, we will show Next
                      // to move to next field
                      textInputAction: TextInputAction.next,
                      // when finish this filed not all form, then move to next
                      onFieldSubmitted: (_) {
                        // when finish this field, move to next field which is price field
                        // and this is reason for using FocusNode
                        FocusScope.of(context).requestFocus(_imageUrlFocusNode);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'please provide a value';
                        if (val.length < 10)
                          return 'Should be at least 10 characters long!';
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = SingleProductProvider(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: val,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    /*Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          alignment: _imageUrlController.text.isEmpty
                              ? Alignment.center
                              : null,
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8.0, right: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text(
                                  "Enter a URL",
                                  textAlign: TextAlign.center,
                                )
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // if we declare initialValue we cannot declare controller, and vice versa
                            //initialValue: _initialValues['description'],
                            controller: _imageUrlController,
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            focusNode: _imageUrlFocusNode,
                            validator: (val) {
                              if (val.isEmpty) return 'please provide an image';
                              if (!val.startsWith('http') &&
                                  !val.startsWith('https'))
                                return 'please enter a valid URL';
                              if (!val.endsWith('png') &&
                                  !val.endsWith('jpg') &&
                                  !val.endsWith('jpeg'))
                                return 'please enter a valid URL';
                              return null;
                            },
                            onSaved: (val) {
                              _editedProduct = SingleProductProvider(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: val,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),*/

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          alignment:
                              _pickedImage == null ? Alignment.center : null,
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8.0, right: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _checkImage(),
                        ),
                        Expanded(
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text('Upload image'),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                    Opacity(
                      opacity: _showImageErrMsg ? 1 : 0,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Please add your image!!",
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _checkImage() {
    if (_loadImage) return CircularProgressIndicator();

    if (_pickedImage == null) {
      if (_editedProduct.id == null) {
        return Text(
          "Image will appear here",
          textAlign: TextAlign.center,
        );
      } else {
        return Image.network(
          _editedProduct.imageUrl,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        );
      }
    } else {
      return FittedBox(
        child: Image.file(
          _pickedImage,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      );
    }
    /*
    _editedProduct.id == null
                              ? _loadImage
                                  ? CircularProgressIndicator()
                                  : _pickedImage == null
                                      ? Text(
                                          "Image will appear here",
                                          textAlign: TextAlign.center,
                                        )
                                      : FittedBox(
                                          child: Image.file(
                                            _pickedImage,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          ),
                                        )
                              : Image.network(
                                  _editedProduct.imageUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
    */
  }

  void _pickImage() async {
    final pickedImageFile = await _picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    setState(() {
      _loadImage = true;
    });

    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });

      _uploadImageToStorage().then(
        (imageUrl) {
          setState(() {
            _loadImage = false;
          });
          return _editedProduct = SingleProductProvider(
            id: _editedProduct.id,
            title: _editedProduct.title,
            description: _editedProduct.description,
            price: _editedProduct.price,
            imageUrl: imageUrl,
            isFavorite: _editedProduct.isFavorite,
          );
        },
      ).catchError(
        () => setState(() => _loadImage = false),
      );
    } else {
      setState(() {
        _loadImage = false;
      });
    }
  }

  Future<String> _uploadImageToStorage() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final storageRef = FirebaseStorage.instance.ref().child(auth.userId).child(
        _editedProduct.id != null
            ? _editedProduct.id
            : DateTime.now().toIso8601String() + '.jpg');

    await storageRef.putFile(_pickedImage);

    // get image url to download it or anything else
    final imageUrl = await storageRef.getDownloadURL();

    print(imageUrl);

    return imageUrl;
  }
}
