

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:productos_app/providers/product_form_provider.dart';
import 'package:productos_app/services/products_service.dart';
import 'package:provider/provider.dart';

import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';

import 'package:image_picker/image_picker.dart';


class ProductScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

      final productService = Provider.of<ProductsService>(context);

      return ChangeNotifierProvider(
        create: ( _ ) => ProductFormProvider(productService.selectedProduct),
        child: _ProductScreenBody(productService: productService) ,
        );
    
    
    //return _ProductScreenBody(productService: productService);
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    super.key,
    required this.productService,
  });

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
       // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            
            Stack(children: [
              ProductImage(url: productService.selectedProduct.picture),
              Positioned(
                top: 40,
                left: 5,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon (Icons.arrow_back_ios_new, size: 40, color: Colors.white,),
                  )
                ),
                 Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: ()  async {
                    //TODO camara a galeria
                      final picker = new ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 100
                      );

                        if (pickedFile == null){
                          print('No se seleciono nada');
                          return;
                        }
                        productService.updateSelectedProductImage(pickedFile.path);
                        
                  },
                  icon:const Icon (Icons.camera_alt_outlined, size: 40, color: Colors.white,),
                  )
                )
            ],
            ),

            _ProductForm(),

           const SizedBox( height: 100),
          
          ]
          ), 
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child:  productService.isSaving
          ? CircularProgressIndicator(color: Colors.white,)
          : Icon (Icons.save_outlined),
          onPressed: productService.isSaving
          ? null
          : () async{
            //Todo Guardar producto
            
            if (!productForm.isValidForm()) return;
            final String? imageUrl = await productService.uploadImage();

            if (imageUrl != null) productForm.product.picture = imageUrl;


            await productService.saveOrCreateProduct(productForm.product);
          }
          ),

   );
  }
}

class _ProductForm extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final producForm = Provider.of<ProductFormProvider>(context);
    final product = producForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20) ,
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: producForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [


                SizedBox(height: 10),

                TextFormField(
                  initialValue: product.name,
                  onChanged: (value) => product.name = value,
                  validator: (value) {
                    if (value == null || value.length < 1) 
                    return 'El nombre es obligatorio';
                  },
                    decoration: InputDecorations.authInputDecoration(
                      hintText: 'Nombre del producto', 
                      labelText: 'Nombre',
                      ),
                ),


                const SizedBox(height: 30),


                TextFormField(
                  
                  initialValue: '${product.price}',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
                  ],
                  onChanged: (value) {
                    if (double.tryParse(value) == null){
                      product.price = 0;
                    }else{
                      product.price = double.parse(value);
                    }
                    
                    },
                  keyboardType: TextInputType.number,
                  
                    decoration: InputDecorations.authInputDecoration(
                      hintText: '\$150', 
                      labelText: 'Precio'
                      ),
                ),
                const SizedBox(height: 30),

                 const  SizedBox(height: 30),
                 SwitchListTile.adaptive(
                  value: product.available, 
                  title: const Text('Disponible'),
                  activeColor: Colors.indigo,
                  onChanged: producForm.updateAvailability
                  )


            ],
          )
          ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(25), bottomLeft: Radius.circular(25)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0,5),
        blurRadius: 5,
      )
    ]
  );
}